import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/themed_text.dart';
import '../../../core/widgets/themed_view.dart';
import '../../providers/alumni_detail_provider.dart';

/// Alumni Detail Screen - Displays full alumni information
class AlumniDetailScreen extends StatefulWidget {
  final String alumniId;

  const AlumniDetailScreen({
    super.key,
    required this.alumniId,
  });

  @override
  State<AlumniDetailScreen> createState() => _AlumniDetailScreenState();
}

class _AlumniDetailScreenState extends State<AlumniDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlumniDetailProvider>().loadAlumni(widget.alumniId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => context.read<AlumniDetailProvider>(),
      child: Consumer<AlumniDetailProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: provider.alumni != null
                  ? ThemedTitle(provider.alumni!.name)
                  : const ThemedText('Alumni Detail'),
              actions: [
                if (provider.alumni != null) ...[
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditDialog(context, provider),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmDelete(context, provider),
                    tooltip: 'Delete',
                    color: AppColors.error,
                  ),
                ],
              ],
            ),
            body: _buildContent(provider),
          );
        },
      ),
    );
  }

  Widget _buildContent(AlumniDetailProvider provider) {
    if (provider.isLoading) {
      return const LoadingIndicator(message: 'Loading alumni...');
    }

    if (provider.hasError) {
      return ErrorBanner(
        message: provider.error,
        onRetry: () => provider.loadAlumni(widget.alumniId),
      );
    }

    if (provider.alumni == null) {
      return const EmptyState(
        title: 'Alumni not found',
        icon: Icons.person_off,
      );
    }

    final alumni = provider.alumni!;

    return RefreshIndicator(
      onRefresh: () => provider.refreshAlumni(alumni.id),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar and Name Header
          _buildHeader(alumni),

          const SizedBox(height: 24),

          // Basic Information
          _buildSection(
            title: 'Basic Information',
            icon: Icons.info_outline,
            children: [
              _buildInfoRow('Name', alumni.name),
              _buildInfoRow('Phone', alumni.phone),
              _buildInfoRow('Batch Year', alumni.batchYear),
            ],
          ),

          const SizedBox(height: 16),

          // Location Information
          if (alumni.village.isNotEmpty ||
              alumni.postOffice.isNotEmpty ||
              alumni.upazila.isNotEmpty ||
              alumni.district.isNotEmpty)
            _buildSection(
              title: 'Location Information',
              icon: Icons.location_on,
              children: [
                if (alumni.village.isNotEmpty)
                  _buildInfoRow('Village', alumni.village),
                if (alumni.postOffice.isNotEmpty)
                  _buildInfoRow('Post Office', alumni.postOffice),
                if (alumni.upazila.isNotEmpty)
                  _buildInfoRow('Upazila', alumni.upazila),
                if (alumni.district.isNotEmpty)
                  _buildInfoRow('District', alumni.district),
              ],
            ),

          const SizedBox(height: 16),

          // Professional Information
          if (alumni.position.isNotEmpty || alumni.currentlyDoing.isNotEmpty)
            _buildSection(
              title: 'Professional Information',
              icon: Icons.work,
              children: [
                if (alumni.position.isNotEmpty)
                  _buildInfoRow('Position', alumni.position),
                if (alumni.currentlyDoing.isNotEmpty)
                  _buildInfoRow('Currently Doing', alumni.currentlyDoing,
                      multiline: true),
              ],
            ),

          const SizedBox(height: 16),

          // Achievements
          if (alumni.achievements.isNotEmpty)
            _buildSection(
              title: 'Achievements',
              icon: Icons.emoji_events,
              children: [
                _buildInfoRow('', alumni.achievements, multiline: true),
              ],
            ),

          const SizedBox(height: 24),

          // Timestamps
          _buildSection(
            title: 'Metadata',
            icon: Icons.access_time,
            children: [
              _buildInfoRow(
                'Created',
                DateFormat('MMM dd, yyyy - hh:mm a').format(alumni.createdAt),
              ),
              _buildInfoRow(
                'Updated',
                DateFormat('MMM dd, yyyy - hh:mm a').format(alumni.updatedAt),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(dynamic alumni) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Avatar(
            name: alumni.name,
            size: 80,
          ),
          const SizedBox(height: 16),
          ThemedTitle(
            alumni.name,
            maxLines: 2,
          ),
          if (alumni.position.isNotEmpty) ...[
            const SizedBox(height: 8),
            ThemedSubtitle(alumni.position),
          ],
          if (alumni.batchYear.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ThemedText(
                'Batch ${alumni.batchYear}',
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return ThemedCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                ThemedTitle(title),
              ],
            ),
          ),
          const Divider(height: 1),
          // Section Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool multiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 120,
              child: ThemedSubtitle(
                '$label:',
                maxLines: 2,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: ThemedText(
              value,
              maxLines: multiline ? null : 2,
              overflow: multiline ? null : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, AlumniDetailProvider provider) {
    // For now, just show a message
    // In a full implementation, you would navigate to an edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon')),
    );
  }

  void _confirmDelete(BuildContext context, AlumniDetailProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const ThemedText('Delete Alumni'),
        content: const ThemedText(
          'Are you sure you want to delete this alumni? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const ThemedText('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.deleteAlumni(widget.alumniId);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alumni deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const ThemedText(
              'Delete',
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
