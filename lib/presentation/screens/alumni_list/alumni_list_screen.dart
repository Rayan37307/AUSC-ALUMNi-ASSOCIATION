import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animated_avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/info_tile.dart';
import '../../../core/widgets/themed_text.dart';
import '../../../data/models/alumni.dart';
import '../../providers/alumni_list_provider.dart';
import '../../providers/theme_provider.dart';

class AlumniListScreen extends StatefulWidget {
  const AlumniListScreen({super.key});

  @override
  State<AlumniListScreen> createState() => _AlumniListScreenState();
}

class _AlumniListScreenState extends State<AlumniListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissKeyboard,
      child: ChangeNotifierProvider(
        create: (context) => context.read<AlumniListProvider>(),
        child: Consumer<AlumniListProvider>(
          builder: (context, provider, child) {
            return Scaffold(
              extendBodyBehindAppBar: true,
              body: SingleChildScrollView(
                child: Column(
                  children: [_buildHeader(), _buildContent(provider)],
                ),
              ),
              floatingActionButton: _buildFAB(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkBackground, AppColors.darkSurface]
              : [AppColors.primaryStart, AppColors.primaryEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildImageBanner(),
            _buildBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppConstants.appName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildThemeToggle(themeProvider),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: _buildSearchBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'images/TABIA.png',
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 150,
              color: AppColors.primary.withValues(alpha: 0.2),
              child: const Center(
                child: Icon(Icons.broken_image_rounded, size: 40),
              ),
            );
          },
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2);
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.primaryEnd.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.school_rounded,
                size: 100,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to Alumni Network',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Connect with fellow alumni',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2);
  }

  Widget _buildThemeToggle(ThemeProvider provider) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        provider.toggleTheme();
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return RotationTransition(
              turns: Tween(begin: 0.5, end: 1.0).animate(animation),
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: Icon(
            provider.isDarkMode
                ? Icons.wb_sunny_rounded
                : Icons.nightlight_round,
            key: ValueKey(provider.isDarkMode),
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Consumer<AlumniListProvider>(
        builder: (context, provider, child) {
          return TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (value) => provider.search(value),
            style: TextStyle(
              color: isDark ? AppColors.darkText : AppColors.lightText,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'Search alumni...',
              hintStyle: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: _isSearchFocused
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
              ),
              suffixIcon: provider.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        provider.clearSearch();
                      },
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(AlumniListProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          if (provider.searchQuery.isNotEmpty && provider.alumni.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${provider.alumni.length} result${provider.alumni.length > 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          _buildListContent(provider),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildListContent(AlumniListProvider provider) {
    if (provider.isLoading) {
      return const LoadingState(message: 'Loading alumni...');
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
        subtitle: 'Be the first to add an alumni to the network!',
        icon: Icons.people_outline_rounded,
        onAction: () => context.push('/add-alumni'),
        actionLabel: 'Add Alumni',
      );
    }

    if (provider.hasNoResults) {
      return EmptyStateSearch(query: provider.searchQuery);
    }

    return RefreshIndicator(
      onRefresh: () => provider.refreshAlumni(),
      color: AppColors.primary,
      child: ListView.builder(
        itemCount: provider.alumni.length,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemBuilder: (context, index) {
          final alumni = provider.alumni[index];
          return _buildAlumniCard(alumni, index);
        },
      ),
    );
  }

  Widget _buildAlumniCard(Alumni alumni, int index) {
    return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GradientBorderCard(
            onTap: () {
              HapticFeedback.selectionClick();
              context.push('/alumni/${alumni.id}');
            },
            borderColors: [
              AppColors.avatarColors[index % AppColors.avatarColors.length],
              AppColors.avatarColors[(index + 1) %
                  AppColors.avatarColors.length],
            ],
            child: Row(
              children: [
                Hero(
                  tag: 'avatar_${alumni.id}',
                  child: AnimatedAvatar(
                    name: alumni.name,
                    size: 56,
                    showRing: false,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alumni.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (alumni.position.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          alumni.position,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (alumni.batchYear.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        GradientChip(
                          label: 'Batch ${alumni.batchYear}',
                          icon: Icons.school_rounded,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 50 * index),
          duration: 300.ms,
        )
        .slideX(
          begin: 0.1,
          delay: Duration(milliseconds: 50 * index),
          duration: 300.ms,
        );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.push('/add-alumni');
          },
          child: const Icon(Icons.add_rounded, size: 28),
        )
        .animate()
        .fadeIn(delay: 500.ms)
        .scale(
          begin: const Offset(0, 0),
          delay: 500.ms,
          curve: Curves.elasticOut,
        );
  }
}
