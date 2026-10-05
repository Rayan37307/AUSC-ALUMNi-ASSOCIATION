import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/network_photo.dart';
import '../../../core/widgets/themed_text.dart';
import '../../../data/models/photo.dart';
import '../../providers/auth_provider.dart';

/// Browsable photo gallery.
///
/// Everyone can view. Only accounts listed in the Supabase `admins` table see
/// the upload and delete actions; RLS enforces the same rule server-side.
class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  static const String _bucket = 'gallery';

  final _picker = ImagePicker();
  final _captionController = TextEditingController();

  List<Photo> _photos = const [];
  bool _isLoading = true;
  bool _isUploading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  bool get _isAdmin => context.read<AuthProvider>().isAdmin;

  Future<void> _loadPhotos() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = '';
      });
    }

    try {
      final response = await Supabase.instance.client
          .from('photos')
          .select('*')
          .order('created_at', ascending: false);

      final photos = (response as List)
          .map((row) => Photo.fromSupabase(row as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        _photos = photos;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load photos. Pull to retry.';
        _isLoading = false;
      });
      debugPrint('Load photos failed: $e');
    }
  }

  Future<void> _refresh() async {
    await _loadPhotos();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery updated')),
    );
  }

  Future<void> _upload() async {
    final messenger = ScaffoldMessenger.of(context);
    final caption = _captionController.text.trim();

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 2000,
    );
    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      final auth = Supabase.instance.client.auth.currentUser;
      if (auth == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Sign in to add photos')),
        );
        return;
      }

      final bytes = await picked.readAsBytes();
      final extension = (picked.name.split('.').last).toLowerCase();
      final safeExtension = extension.isEmpty ? 'jpg' : extension;
      final path =
          '${auth.id}/${DateTime.now().millisecondsSinceEpoch}.$safeExtension';

      await Supabase.instance.client.storage
          .from(_bucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$safeExtension',
              upsert: false,
            ),
          );

      final url = Supabase.instance.client.storage
          .from(_bucket)
          .getPublicUrl(path);

      await Supabase.instance.client.from('photos').insert({
        'url': url,
        'caption': caption,
        'uploaded_by': auth.id,
      });

      _captionController.clear();
      await _loadPhotos();

      if (!mounted) return;
      HapticFeedback.mediumImpact();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Photo added to the gallery'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('Upload failed: $e');
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Upload failed. Only the admin can add photos.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _confirmDelete(Photo photo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete photo?'),
        content: const Text('This removes it from the gallery for everyone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await Supabase.instance.client.from('photos').delete().eq('id', photo.id);

      // Drop the file too, otherwise storage fills up with orphans.
      final uri = Uri.tryParse(photo.url);
      final marker = '/$_bucket/';
      final index = uri?.path.indexOf(marker) ?? -1;
      if (uri != null && index != -1) {
        final objectPath = uri.path.substring(index + marker.length);
        if (objectPath.isNotEmpty) {
          try {
            await Supabase.instance.client.storage
                .from(_bucket)
                .remove([objectPath]);
          } catch (e) {
            debugPrint('Storage cleanup failed: $e');
          }
        }
      }

      await _loadPhotos();
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Photo deleted'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('Delete failed: $e');
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not delete that photo'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _openViewer(Photo photo) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _PhotoViewer(
          photo: photo,
          canDelete: _isAdmin,
          onDelete: () {
            Navigator.of(context).pop();
            _confirmDelete(photo);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _isAdmin;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Photo Gallery'),
        actions: [
          if (isAdmin)
            IconButton(
              tooltip: 'Add photo',
              onPressed: _isUploading ? null : _upload,
              icon: const Icon(Icons.add_a_photo_outlined),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isUploading) const LinearProgressIndicator(),
          if (isAdmin) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: GlassCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _captionController,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: 'Caption (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GradientButton(
                      text: _isUploading ? 'Adding' : 'Add',
                      icon: Icons.upload_rounded,
                      height: 46,
                      borderRadius: 100,
                      isLoading: _isUploading,
                      onPressed: _isUploading ? null : _upload,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: ThemedText(
          _error,
          style: const TextStyle(color: AppColors.error),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_photos.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.photo_library_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  const ThemedText(
                    'No photos yet',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const ThemedText(
                    'Photos shared by the admin will appear here.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _photos.length,
        itemBuilder: (context, index) => _buildPhotoCard(_photos[index]),
      ),
    );
  }

  Widget _buildPhotoCard(Photo photo) {
    return GestureDetector(
      onTap: () => _openViewer(photo),
      child: Stack(
        fit: StackFit.expand,
        children: [
          NetworkPhoto(
            url: photo.url,
            placeholder: ColoredBox(
              color: AppColors.lightSurfaceVariant,
              child: const Center(
                child: Icon(Icons.image_outlined, color: Colors.grey),
              ),
            ),
          ),
          if (photo.caption != null && photo.caption!.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  photo.caption!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Full-screen viewer with pinch-zoom.
class _PhotoViewer extends StatelessWidget {
  final Photo photo;
  final bool canDelete;
  final VoidCallback onDelete;

  const _PhotoViewer({
    required this.photo,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          photo.caption?.isNotEmpty == true ? photo.caption! : 'Photo',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          if (canDelete)
            IconButton(
              tooltip: 'Delete',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: photo.url.isEmpty
              ? const Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.white24,
                  size: 72,
                )
              : Image.network(
                  photo.url,
                  fit: BoxFit.contain,
                  webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white24,
                    size: 72,
                  ),
                ),
        ),
      ),
    );
  }
}

