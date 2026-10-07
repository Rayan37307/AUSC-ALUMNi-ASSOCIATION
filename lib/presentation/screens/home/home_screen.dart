import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animated_avatar.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/content/school_content.dart';
import '../../../data/models/alumni.dart';
import '../../providers/alumni_list_provider.dart';
import '../../providers/auth_provider.dart';

import 'widgets/banner_carousel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlumniListProvider>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => provider.refreshAlumni(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              const _Greeting(),
              const SizedBox(height: 20),
              const BannerCarousel(slides: SchoolContent.banners),
              const SizedBox(height: 20),
              const _LegacyPill(),
              const SizedBox(height: 16),
              const _AboutCard(),
              const SizedBox(height: 32),
              const SectionHeader(title: 'Explore'),
              const SizedBox(height: 12),
              const _ExploreChips(),
              const SizedBox(height: 32),
              _StatsRow(provider: provider),
              const SizedBox(height: 32),
              _RecentMembers(provider: provider),
              const SizedBox(height: 32),
              const _MottoCard(),
            ]
                .animate(interval: 60.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.06, curve: Curves.easeOutCubic),
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final textTheme = Theme.of(context).textTheme;
    final greeting = auth.isSignedIn && auth.firstName.isNotEmpty
        ? 'Welcome back, ${auth.firstName}'
        : 'Welcome to';

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              SchoolContent.logoBanner,
              fit: BoxFit.cover,
              // The crest sits on the left of the banner image.
              alignment: const Alignment(-0.82, 0),
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.school_rounded, color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: textTheme.bodySmall),
              Text(
                SchoolContent.associationName,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Glassy pill showing how long the school has been around.
class _LegacyPill extends StatelessWidget {
  const _LegacyPill();

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      radius: 100,
      padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
      onTap: () => context.go('/school'),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            alignment: Alignment.center,
            child: Text(
              '${SchoolContent.yearsOfLegacy}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Years of legacy · Since ${SchoolContent.establishedYear}',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SoftCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'About the Association',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.format_quote_rounded,
                      size: 28,
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(SchoolContent.aboutShort, style: textTheme.bodyMedium),
              ],
            ),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 14, 14),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Kishoreganj',
                    style: textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkPillButton(
                  label: 'Learn More',
                  onPressed: () => context.go('/school'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreChips extends StatelessWidget {
  const _ExploreChips();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        QuickActionChip(
          icon: Icons.groups_2_outlined,
          label: 'Alumni Directory',
          onTap: () => context.go('/alumni'),
        ),
        QuickActionChip(
          icon: Icons.person_add_alt_outlined,
          label: 'Join Network',
          onTap: () => context.push('/add-alumni'),
        ),
        QuickActionChip(
          icon: Icons.account_balance_outlined,
          label: 'Our School',
          onTap: () => context.go('/school'),
        ),
        QuickActionChip(
          icon: Icons.history_edu_outlined,
          label: 'History',
          onTap: () => context.go('/school'),
        ),
        QuickActionChip(
          icon: Icons.co_present_outlined,
          label: 'Teachers',
          onTap: () => context.go('/teachers'),
        ),
        QuickActionChip(
          icon: Icons.settings_outlined,
          label: 'Settings',
          onTap: () => context.go('/settings'),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final AlumniListProvider provider;

  const _StatsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final members = provider.allAlumni;
    final hasData = members.isNotEmpty;
    final batches = members.map((a) => a.batchYear).toSet().length;

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            value: hasData ? '${members.length}' : '—',
            label: 'Members',
            icon: Icons.people_alt_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            value: hasData ? '$batches' : '—',
            label: 'Batches',
            icon: Icons.layers_outlined,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _StatTile(
            value: '${SchoolContent.establishedYear}',
            label: 'Founded',
            icon: Icons.flag_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SoftCard(
      radius: 24,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          Text(label, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _RecentMembers extends StatelessWidget {
  final AlumniListProvider provider;

  const _RecentMembers({required this.provider});

  @override
  Widget build(BuildContext context) {
    final members = provider.allAlumni.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent Members',
          actionLabel: members.isEmpty ? null : 'See all',
          onAction: () => context.go('/alumni'),
        ),
        const SizedBox(height: 12),
        if (provider.isLoading && members.isEmpty)
          const SizedBox(
            height: 150,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (members.isEmpty)
          _JoinPrompt(hasError: provider.hasError)
        else
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: members.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _MemberCard(alumni: members[index]),
            ),
          ),
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  final Alumni alumni;

  const _MemberCard({required this.alumni});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 140,
      child: SoftCard(
        radius: 24,
        padding: const EdgeInsets.all(14),
        onTap: () => context.push('/alumni/${alumni.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedAvatar(name: alumni.name, size: 48, showRing: false),
            const Spacer(),
            Text(
              alumni.name,
              style: textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              alumni.position.isNotEmpty ? alumni.position : 'Alumni',
              style: textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            TagChip(label: 'Batch ${alumni.batchYear}'),
          ],
        ),
      ),
    );
  }
}

class _JoinPrompt extends StatelessWidget {
  final bool hasError;

  const _JoinPrompt({required this.hasError});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SoftCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasError ? 'Directory unavailable' : 'Be the first to join',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasError
                      ? 'We couldn\'t reach the alumni directory. Pull down to try again.'
                      : 'Add your profile and help batchmates find you.',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CircleActionButton(
            icon: hasError ? Icons.refresh_rounded : Icons.arrow_forward_rounded,
            onTap: hasError
                ? () => context.read<AlumniListProvider>().loadAlumni()
                : () => context.push('/add-alumni'),
          ),
        ],
      ),
    );
  }
}

/// E-card style block with the school motto.
class _MottoCard extends StatelessWidget {
  const _MottoCard();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: EmberBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Icon(
                Icons.local_fire_department_rounded,
                size: 180,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TagChip(label: 'Our Motto', onDark: true),
                  const Spacer(),
                  const Text(
                    SchoolContent.mottoBangla,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    SchoolContent.mottoEnglish,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    SchoolContent.tagline.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10.5,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
