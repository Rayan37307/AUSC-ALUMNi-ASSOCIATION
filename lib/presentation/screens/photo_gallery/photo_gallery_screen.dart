import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../data/models/photo.dart';
import '../../providers/auth_provider.dart';

class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  late Future<List<Photo>> _photosFuture;
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _initAdminCheck();
    _photosFuture = _fetchPhotos();
  }

  Future<void> _initAdminCheck() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user != null) {
      // Check if the user is the admin by looking at user metadata or specific ID
      // For now, check if user metadata has isAdmin flag
      final metadata = user.userMetadata;
      final isAdmin = metadata?['isAdmin'] == true ||
          user.id == '00000000-0000-0000-0000-000000000000'; // TODO: Replace with actual admin UUID
      setState(() {
        _isAdmin = isAdmin;
      });
    }
  }

  Future<List<Photo>> _fetchPhotos() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('photos')
        .select('*')
        .order('created_at', ascending: false);
    return (response as List)
        .map((row) => Photo.fromSupabase(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> _uploadPhoto() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a caption'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final supabase = Supabase.instance.client;
    final auth = supabase.auth;

    // For simplicity, we'll store the photo with a placeholder URL
    // In a full implementation, you'd upload to Supabase Storage
    final photo = Photo(
      id: '',
      url: '', // Will be set after actual upload
      caption: _nameController.text,
      uploadedBy: auth.currentUser?.id ?? '',
      createdAt: DateTime.now(),
    );

    final future = supabase
        .from('photos')
        .insert(photo.toSupabaseInsert())
        .select()
        .single()
        .then((_) => _fetchPhotos());

    if (!mounted) return;
    setState(() {
      _photosFuture = future;
      _isLoading = false;
      _nameController.clear();
    });

    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo added successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Photo Gallery'),
        actions: [
          if (_isAdmin)
            IconButton(
              onPressed: () {
                // Show upload dialog
                _showUploadDialog();
              },
              icon: const Icon(Icons.upload_rounded),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          // Filter/sort options
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(Icons.sort, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Sort by: Newest First',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Photos grid
          Expanded(
            child: FutureBuilder<List<Photo>>(
              future: _photosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: AppColors.error),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final photos = snapshot.data!;
                return GridView.builder(
                  controller: _scrollController,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return _buildPhotoCard(photo);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(Photo photo) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Photo placeholder - in a real app, display the actual image
          Container(
            width: double.infinity,
            height: 80,
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: const Center(
              child: Text(
                'Photo',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
            child: Text(
              photo.caption ?? 'No caption',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Upload Photo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextField(
                  controller: _nameController,
                  decoration:
                      const InputDecoration(labelText: 'Caption'),
                ),
                const SizedBox(height: 16),
                // In a full implementation, would have image picker here
                const Text(
                  'Select an image from gallery/camera',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isAdmin ? _uploadPhoto : () {
                // Show error if not admin
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Only admin can upload photos'),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              child: const Text('Upload'),
            ),
          ],
        );
      },
    );
  }
}