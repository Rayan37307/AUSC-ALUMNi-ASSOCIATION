import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animated_avatar.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/models/alumni.dart';
import '../../providers/alumni_list_provider.dart';

class AlumniListScreen extends StatefulWidget {
  const AlumniListScreen({super.key});

  @override
  State<AlumniListScreen> createState() => _AlumniListScreenState();
}

class _AlumniListScreenState extends State<AlumniListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _batch;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Alumni> _visible(AlumniListProvider provider) {
    final source = provider.searchQuery.isEmpty
        ? provider.allAlumni
        : provider.alumni;
    if (provider.hasNoResults) return const [];
    if (_batch == null) return source;
    return source.where((a) => a.batchYear == _batch).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlumniListProvider>();
    final visible = _visible(provider);
    final batches =
        provider.allAlumni
            .map((a) => a.batchYear)
            .where((b) => b.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => provider.refreshAlumni(),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  sliver: SliverList.list(
                    children: [
                      PageTitle(
                        subtitle: provider.allAlumni.isEmpty
                            ? 'Directory'
                            : '${provider.allAlumni.length} members',
                        title: 'Alumni',
                        trailing: CircleActionButton(
                          icon: Icons.person_add_alt_1_outlined,
                          tooltip: 'Join the network',
                          onTap: () => context.push('/add-alumni'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSearchField(provider),
                      const SizedBox(height: 14),
                      if (batches.isNotEmpty) _buildBatchFilter(batches),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                ..._buildBody(provider, visible),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(AlumniListProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(100),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: provider.search,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search name, profession, address…',
          filled: false,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: provider.searchQuery.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _searchController.clear();
                    provider.clearSearch();
                  },
                ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildBatchFilter(List<String> batches) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterPill(
            label: 'All batches',
            selected: _batch == null,
            onTap: () => setState(() => _batch = null),
          ),
          for (final batch in batches)
            _FilterPill(
              label: batch,
              selected: _batch == batch,
              onTap: () => setState(() => _batch = batch),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildBody(AlumniListProvider provider, List<Alumni> visible) {
    Widget fill(Widget child) => SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );

    if (provider.isLoading && provider.allAlumni.isEmpty) {
      return [
        fill(
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ];
    }

    if (provider.hasError && provider.allAlumni.isEmpty) {
      return [
        fill(
          _StatusMessage(
            icon: Icons.cloud_off_rounded,
            title: 'Directory unavailable',
            message:
                'We couldn\'t reach the alumni directory. Check your '
                'connection and try again.',
            actionLabel: 'Try Again',
            onAction: provider.loadAlumni,
          ),
        ),
      ];
    }

    if (provider.allAlumni.isEmpty) {
      return [
        fill(
          _StatusMessage(
            icon: Icons.groups_2_outlined,
            title: 'No members yet',
            message: 'Be the first to add your profile to the directory.',
            actionLabel: 'Join the Network',
            onAction: () => context.push('/add-alumni'),
          ),
        ),
      ];
    }

    if (visible.isEmpty) {
      return [
        fill(
          const _StatusMessage(
            icon: Icons.search_off_rounded,
            title: 'No matches',
            message: 'Try a different name or batch.',
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        sliver: SliverList.separated(
          itemCount: visible.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              _AlumniCard(alumni: visible[index])
                  .animate()
                  .fadeIn(delay: (30 * (index % 12)).ms, duration: 300.ms)
                  .slideY(begin: 0.08, curve: Curves.easeOutCubic),
        ),
      ),
    ];
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = selected
        ? (isDark ? Colors.white : AppColors.ink)
        : (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final fg = selected
        ? (isDark ? AppColors.ink : Colors.white)
        : (isDark ? AppColors.darkText : AppColors.lightText);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AlumniCard extends StatelessWidget {
  final Alumni alumni;

  const _AlumniCard({required this.alumni});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final place = alumni.currentAddress.isNotEmpty
        ? alumni.currentAddress
        : alumni.permanentAddress;

    return SoftCard(
      radius: 26,
      padding: const EdgeInsets.all(14),
      onTap: () => context.push('/alumni/${alumni.id}'),
      child: Row(
        children: [
          Hero(
            tag: 'avatar_${alumni.id}',
            child: AnimatedAvatar(name: alumni.name, size: 60, showRing: false),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TagChip(label: 'Batch ${alumni.batchYear}'),
                const SizedBox(height: 6),
                Text(
                  alumni.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (alumni.position.isNotEmpty ||
                    alumni.currentlyDoing.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    alumni.position.isNotEmpty
                        ? alumni.position
                        : alumni.currentlyDoing,
                    style: textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (place.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          place,
                          style: textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: textTheme.bodySmall?.color),
        ],
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StatusMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: isDark ? AppColors.tagBgDark : AppColors.tagBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(message, style: textTheme.bodyMedium, textAlign: TextAlign.center),
          if (actionLabel != null) ...[
            const SizedBox(height: 22),
            InkPillButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
