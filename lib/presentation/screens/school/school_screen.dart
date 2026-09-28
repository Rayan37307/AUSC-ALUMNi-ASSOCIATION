import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/content/school_content.dart';

class SchoolScreen extends StatelessWidget {
  const SchoolScreen({super.key});

  Future<void> _openDirections(BuildContext context) async {
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': SchoolContent.mapsQuery,
    });
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open maps')));
    }
  }

  void _share() {
    Share.share(
      '${SchoolContent.schoolName}\n'
      'Est. ${SchoolContent.establishedYear} · ${SchoolContent.location}\n'
      '${SchoolContent.tagline}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const PageTitle(subtitle: 'About', title: 'Our School'),
            const SizedBox(height: 20),
            _HeroCard(
              onDirections: () => _openDirections(context),
              onShare: _share,
            ),
            const SizedBox(height: 16),
            const _FactsRow(),
            const SizedBox(height: 32),
            const SectionHeader(title: "Principal's Message"),
            const SizedBox(height: 12),
            const _PrincipalMessage(),
            const SizedBox(height: 32),
            const SectionHeader(title: 'Who We Are'),
            const SizedBox(height: 12),
            const _TextCard(
              title: 'The School',
              body: SchoolContent.schoolAbout,
              icon: Icons.account_balance_outlined,
            ),
            const SizedBox(height: 12),
            const _TextCard(
              title: 'The Association',
              body: '${SchoolContent.aboutShort} ${SchoolContent.aboutLong}',
              icon: Icons.diversity_3_outlined,
            ),
            const SizedBox(height: 32),
            const SectionHeader(title: 'History'),
            const SizedBox(height: 12),
            const _Timeline(milestones: SchoolContent.history),
            const SizedBox(height: 32),
            const SectionHeader(title: 'Contact'),
            const SizedBox(height: 12),
            const _ContactCard(),
          ]
              .animate(interval: 60.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.06, curve: Curves.easeOutCubic),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final VoidCallback onDirections;
  final VoidCallback onShare;

  const _HeroCard({required this.onDirections, required this.onShare});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SoftCard(
      padding: const EdgeInsets.all(10),
      radius: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 2,
              child: Image.asset(
                SchoolContent.banners.first.image!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const EmberBackground(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TagChip(label: 'School & College'),
                const SizedBox(height: 10),
                Text(
                  SchoolContent.schoolName,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                _IconLine(
                  icon: Icons.location_on_outlined,
                  text: SchoolContent.location,
                ),
                const SizedBox(height: 4),
                _IconLine(
                  icon: Icons.person_outline_rounded,
                  text: 'Founded by ${SchoolContent.founder}',
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: InkPillButton(
                        label: 'Directions',
                        icon: Icons.north_east_rounded,
                        expand: true,
                        onPressed: onDirections,
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleActionButton(
                      icon: Icons.ios_share_rounded,
                      tooltip: 'Share',
                      size: 52,
                      onTap: onShare,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IconLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Row(
      children: [
        Icon(icon, size: 17, color: style?.color),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}

class _FactsRow extends StatelessWidget {
  const _FactsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: _Fact(
            label: 'Established',
            value: '${SchoolContent.establishedYear}',
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: _Fact(label: 'EIIN', value: SchoolContent.eiin),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Fact(
            label: 'Years',
            value: '${SchoolContent.yearsOfLegacy}+',
          ),
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  final String label;
  final String value;

  const _Fact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SoftCard(
      radius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          Text(label, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _TextCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;

  const _TextCard({required this.title, required this.body, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return SoftCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark ? AppColors.tagBgDark : AppColors.tagBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(body, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final List<Milestone> milestones;

  const _Timeline({required this.milestones});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final lineColor = Theme.of(context).dividerColor;

    return SoftCard(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
      child: Column(
        children: [
          for (var i = 0; i < milestones.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 24,
                    child: Column(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          margin: const EdgeInsets.only(top: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        if (i < milestones.length - 1)
                          Expanded(
                            child: Container(
                              width: 2,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: lineColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TagChip(label: milestones[i].year),
                          const SizedBox(height: 6),
                          Text(
                            milestones[i].title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            milestones[i].description,
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PrincipalMessage extends StatelessWidget {
  const _PrincipalMessage();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote_rounded,
            size: 34,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            SchoolContent.principalMessage,
            style: textTheme.bodyLarge?.copyWith(height: 1.7),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 24,
                height: 2,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${SchoolContent.principalName}, Principal',
                  style: textTheme.titleSmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  Future<void> _open(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final divider = Divider(
      height: 1,
      indent: 70,
      endIndent: 18,
      color: Theme.of(context).dividerColor,
    );
    return SoftCard(
      radius: 26,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          _ContactRow(
            icon: Icons.call_outlined,
            label: 'Phone',
            value: SchoolContent.phone,
            onTap: () =>
                _open(context, Uri(scheme: 'tel', path: SchoolContent.phone)),
          ),
          divider,
          _ContactRow(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: SchoolContent.email,
            onTap: () => _open(
              context,
              Uri(scheme: 'mailto', path: SchoolContent.email),
            ),
          ),
          divider,
          _ContactRow(
            icon: Icons.language_rounded,
            label: 'Website',
            value: 'ausc.edu.bd',
            onTap: () => _open(context, Uri.parse(SchoolContent.website)),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.tagBgDark : AppColors.tagBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 19,
                color: isDark ? AppColors.tagTextDark : AppColors.tagText,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: textTheme.bodySmall),
                  Text(value, style: textTheme.titleSmall),
                ],
              ),
            ),
            Icon(Icons.north_east_rounded, size: 18, color: textTheme.bodySmall?.color),
          ],
        ),
      ),
    );
  }
}
