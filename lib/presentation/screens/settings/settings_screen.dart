import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/phone.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/content/school_content.dart';
import '../../providers/alumni_list_provider.dart';
import '../../providers/auth_provider.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String appVersion = '1.0.0';

  Future<void> _refreshDirectory(BuildContext context) async {
    final provider = context.read<AlumniListProvider>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await provider.refreshAlumni();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            provider.hasError
                ? 'Could not refresh the directory'
                : 'Directory updated · ${provider.allAlumni.length} members',
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Failed to refresh the directory'),
        ),
      );
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign back in anytime with your number.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true) await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const PageTitle(subtitle: 'Preferences', title: 'Settings'),
            const SizedBox(height: 20),
            _MembershipCard(
              name: auth.isSignedIn ? auth.displayName : null,
              phone: auth.isSignedIn ? Phone.pretty(auth.phone) : null,
            ),
            const SizedBox(height: 28),
            _Group(
              title: 'Account',
              tiles: auth.isSignedIn
                  ? [
                      _Tile(
                        icon: Icons.logout_rounded,
                        title: 'Sign out',
                        subtitle: Phone.pretty(auth.phone),
                        onTap: () => _confirmSignOut(context),
                      ),
                    ]
                  : [
                      _Tile(
                        icon: Icons.login_rounded,
                        title: 'Sign in',
                        subtitle: 'With your mobile number and password',
                        onTap: () => context.push('/login'),
                      ),
                      _Tile(
                        icon: Icons.how_to_reg_outlined,
                        title: 'Create an account',
                        subtitle: 'Needed to add your profile',
                        onTap: () => context.push('/signup'),
                      ),
                    ],
            ),
            _Group(
              title: 'Directory',
              tiles: [
                _Tile(
                  icon: Icons.person_add_alt_outlined,
                  title: 'Join the network',
                  subtitle: 'Add your profile to the directory',
                  onTap: () => context.push('/add-alumni'),
                ),
                _Tile(
                  icon: Icons.sync_rounded,
                  title: 'Refresh directory',
                  subtitle: 'Fetch the latest member list',
                  onTap: () => _refreshDirectory(context),
                ),
                _Tile(
                  icon: Icons.wifi_tethering_rounded,
                  title: 'Connection status',
                  subtitle: 'Check the link to the database',
                  onTap: () => context.push('/test-connection'),
                ),
              ],
            ),
            _Group(
              title: 'About',
              tiles: [
                _Tile(
                  icon: Icons.account_balance_outlined,
                  title: 'About the school',
                  subtitle: SchoolContent.schoolName,
                  onTap: () => context.go('/school'),
                ),
                _Tile(
                  icon: Icons.ios_share_rounded,
                  title: 'Share the app',
                  subtitle: 'Invite your batchmates',
                  onTap: () => Share.share(
                    'Join the ${SchoolContent.associationName} and reconnect '
                    'with your batchmates from ${SchoolContent.schoolName}.',
                  ),
                ),
                const _Tile(
                  icon: Icons.info_outline_rounded,
                  title: 'Version',
                  trailing: Text(appVersion),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                SchoolContent.tagline,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ]
              .animate(interval: 60.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.06, curve: Curves.easeOutCubic),
        ),
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  final String? name;
  final String? phone;

  const _MembershipCard({this.name, this.phone});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: EmberBackground(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TagChip(
                    label: name == null ? 'Member Network' : 'Signed In',
                    onDark: true,
                  ),
                  const Spacer(),
                  Text(
                    SchoolContent.shortName,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        SchoolContent.logoBanner,
                        fit: BoxFit.cover,
                        alignment: const Alignment(-0.82, 0),
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.school_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name == null || name!.isEmpty
                              ? 'Alumni Association'
                              : name!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          phone ?? SchoolContent.schoolName,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final String title;
  final List<Widget> tiles;

  const _Group({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 10),
            child: Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SoftCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            radius: 26,
            child: Column(
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 70,
                      endIndent: 18,
                      color: Theme.of(context).dividerColor,
                    ),
                  tiles[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
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
                  Text(title, style: textTheme.titleSmall),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? Icon(
                        Icons.chevron_right_rounded,
                        color: textTheme.bodySmall?.color,
                      )
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
