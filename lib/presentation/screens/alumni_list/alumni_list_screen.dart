import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/themed_text.dart';
import '../../../core/widgets/themed_view.dart';
import '../../../data/models/alumni.dart';
import '../../providers/alumni_list_provider.dart';

/// Alumni List Screen - Displays all alumni in a scrollable list
class AlumniListScreen extends StatefulWidget {
  const AlumniListScreen({super.key});

  @override
  State<AlumniListScreen> createState() => _AlumniListScreenState();
}

class _AlumniListScreenState extends State<AlumniListScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => context.read<AlumniListProvider>(),
      child: Consumer<AlumniListProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: const ThemedText(
                AppConstants.schoolName,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => context.push('/add-alumni'),
                  tooltip: 'Add Alumni',
                ),
              ],
            ),
            body: Column(
              children: [
                // Header Banner
                _buildHeaderBanner(),
                
                // Search Bar
                _buildSearchBar(provider),
                
                // Alumni List
                Expanded(
                  child: _buildContent(provider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
      ),
      child: Column(
        children: [
          const Avatar(
            name: 'AUSC',
            size: 64,
          ),
          const SizedBox(height: 12),
          const ThemedText(
            AppConstants.schoolName,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          ThemedText(
            'Alumni Management',
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AlumniListProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search alumni...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: provider.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    provider.clearSearch();
                  },
                )
              : null,
        ),
        onChanged: (value) {
          provider.search(value);
        },
      ),
    );
  }

  Widget _buildContent(AlumniListProvider provider) {
    if (provider.isLoading) {
      return const LoadingIndicator(message: 'Loading alumni...');
    }

    if (provider.hasError) {
      return ErrorBanner(
        message: provider.error,
        onRetry: () => provider.loadAlumni(),
      );
    }

    if (provider.isEmpty) {
      return EmptyState(
        title: 'No alumni yet',
        subtitle: 'Be the first to add an alumni!',
        icon: Icons.people_outline,
        onRefresh: () => provider.loadAlumni(),
      );
    }

    if (provider.hasNoResults) {
      return EmptyState(
        title: 'No results found',
        subtitle: 'Try searching with different keywords',
        icon: Icons.search_off,
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.refreshAlumni(),
      child: ListView.builder(
        itemCount: provider.alumni.length,
        padding: const EdgeInsets.only(bottom: 16),
        itemBuilder: (context, index) {
          final alumni = provider.alumni[index];
          return _buildAlumniCard(alumni);
        },
      ),
    );
  }

  Widget _buildAlumniCard(Alumni alumni) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ThemedCard(
        onTap: () => context.push('/alumni/${alumni.id}'),
        child: Row(
          children: [
            // Avatar
            Avatar(name: alumni.name),
            
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ThemedTitle(
                    alumni.name,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  if (alumni.position.isNotEmpty)
                    ThemedSubtitle(
                      alumni.position,
                      maxLines: 1,
                    ),
                  if (alumni.currentlyDoing.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    ThemedSubtitle(
                      alumni.currentlyDoing,
                      maxLines: 2,
                    ),
                  ],
                ],
              ),
            ),
            
            // Arrow
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
