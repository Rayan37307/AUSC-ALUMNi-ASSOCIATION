import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animated_avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/info_tile.dart';
import '../../../data/models/alumni.dart';
import '../../providers/alumni_detail_provider.dart';
import '../../providers/alumni_list_provider.dart';
import '../../providers/auth_provider.dart';

class AlumniDetailScreen extends StatefulWidget {
  final String alumniId;

  const AlumniDetailScreen({super.key, required this.alumniId});

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

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    try {
      await launchUrl(phoneUri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not launch phone')));
      }
    }
  }

  Future<void> _launchSms(String phone) async {
    final Uri smsUri = Uri(scheme: 'sms', path: phone);
    try {
      await launchUrl(smsUri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch messages')),
        );
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareAlumni() {
    final alumni = context.read<AlumniDetailProvider>().alumni;
    if (alumni == null) return;

    final shareText =
        '''
${alumni.name}
${alumni.position.isNotEmpty ? 'Position: ${alumni.position}' : ''}
${alumni.batchYear.isNotEmpty ? 'Batch: ${alumni.batchYear}' : ''}
${alumni.phone.isNotEmpty ? 'Phone: ${alumni.phone}' : ''}
${alumni.currentlyDoing.isNotEmpty ? 'Currently: ${alumni.currentlyDoing}' : ''}

Shared from AUSC Alumni App
''';

    Share.share(shareText.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AlumniDetailProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          body: _buildContent(provider),
          floatingActionButton: provider.alumni != null && _canManage(provider.alumni!)
              ? _buildFAB(provider)
              : null,
        );
      },
    );
  }

  /// RLS on the alumni table only lets a member update or delete a row they
  /// own, with admins allowed to manage any row. Hide the buttons for everyone
  /// else so the UI does not offer an action the server will reject.
  bool _canManage(Alumni alumni) {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null || userId.isEmpty) return false;
    if (alumni.ownerId == null || alumni.ownerId!.isEmpty) {
      // Unowned rows (created before ownership existed) are admin-only.
      return context.read<AuthProvider>().isAdmin;
    }
    return alumni.ownerId == userId || context.read<AuthProvider>().isAdmin;
  }

  Widget _buildContent(AlumniDetailProvider provider) {
    if (provider.isLoading) {
      return const LoadingState(message: 'Loading alumni...');
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
        icon: Icons.person_off_rounded,
      );
    }

    final alumni = provider.alumni!;

    return CustomScrollView(
      slivers: [
        _buildAppBar(alumni, provider),
        SliverToBoxAdapter(child: _buildBody(alumni)),
      ],
    );
  }

  Widget _buildAppBar(Alumni alumni, AlumniDetailProvider provider) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _shareAlumni,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.share_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Hero(
                  tag: 'avatar_${alumni.id}',
                  child: GradientRingAvatar(
                    name: alumni.name,
                    size: 100,
                    ringThickness: 5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                      alumni.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .slideY(begin: 0.3, delay: 100.ms),
                if (alumni.position.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                        alumni.position,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 150.ms)
                      .slideY(begin: 0.3, delay: 150.ms),
                ],
                if (alumni.batchYear.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Batch ${alumni.batchYear}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .scale(begin: const Offset(0.8, 0.8), delay: 200.ms),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(Alumni alumni) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (alumni.phone.isNotEmpty) ...[
              _buildContactActions(alumni),
              const SizedBox(height: 24),
            ],
            if (alumni.currentAddress.isNotEmpty ||
                alumni.permanentAddress.isNotEmpty) ...[
              _buildSection(
                title: 'Address',
                icon: Icons.location_on_rounded,
                delay: 100,
                children: [
                  if (alumni.currentAddress.isNotEmpty)
                    InfoTile(
                      label: 'Current Address',
                      value: alumni.currentAddress,
                      icon: Icons.location_on_rounded,
                    ),
                  if (alumni.permanentAddress.isNotEmpty)
                    InfoTile(
                      label: 'Permanent Address',
                      value: alumni.permanentAddress,
                      icon: Icons.home_rounded,
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            if (alumni.currentlyDoing.isNotEmpty) ...[
              _buildSection(
                title: 'Currently Doing',
                icon: Icons.work_rounded,
                delay: 200,
                children: [
                  InfoTile(
                    label: '',
                    value: alumni.currentlyDoing,
                    icon: Icons.description_rounded,
                    showCopy: false,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            _buildSection(
              title: 'Member Since',
              icon: Icons.access_time_rounded,
              delay: 400,
              children: [
                InfoTile(
                  label: 'Created',
                  value: DateFormat('MMMM dd, yyyy').format(alumni.createdAt),
                  icon: Icons.calendar_today_rounded,
                ),
                InfoTile(
                  label: 'Last Updated',
                  value: DateFormat('MMMM dd, yyyy').format(alumni.updatedAt),
                  icon: Icons.update_rounded,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildContactActions(Alumni alumni) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _ContactButton(
              icon: Icons.phone_rounded,
              label: 'Call',
              onTap: () => _launchPhone(alumni.phone),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ContactButton(
              icon: Icons.message_rounded,
              label: 'Message',
              onTap: () => _launchSms(alumni.phone),
              colors: [AppColors.secondaryStart, AppColors.secondaryEnd],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ContactButton(
              icon: Icons.copy_rounded,
              label: 'Copy',
              onTap: () => _copyToClipboard(alumni.phone, 'Phone number'),
              colors: [AppColors.info, AppColors.info.withValues(alpha: 0.8)],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    int delay = 0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 100 + delay))
            .slideX(begin: -0.1, delay: Duration(milliseconds: 100 + delay)),
        const SizedBox(height: 12),
        GlassCard(
              padding: const EdgeInsets.all(4),
              child: Column(children: children),
            )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 200 + delay))
            .slideY(begin: 0.1, delay: Duration(milliseconds: 200 + delay)),
      ],
    );
  }

  Widget _buildFAB(AlumniDetailProvider provider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
              heroTag: 'edit',
              onPressed: () => _showEditDialog(provider),
              backgroundColor: AppColors.info,
              child: const Icon(Icons.edit_rounded, size: 20),
            )
            .animate()
            .fadeIn(delay: 300.ms)
            .scale(begin: const Offset(0, 0), delay: 300.ms),
        const SizedBox(height: 8),
        FloatingActionButton(
              heroTag: 'delete',
              onPressed: () => _confirmDelete(provider),
              backgroundColor: AppColors.error,
              child: const Icon(Icons.delete_rounded),
            )
            .animate()
            .fadeIn(delay: 400.ms)
            .scale(
              begin: const Offset(0, 0),
              delay: 400.ms,
              curve: Curves.elasticOut,
            ),
      ],
    );
  }

  void _showEditDialog(AlumniDetailProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit functionality coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmDelete(AlumniDetailProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Alumni'),
        content: const Text(
          'Are you sure you want to delete this alumni? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          GradientButton(
            text: 'Delete',
            onPressed: () async {
              Navigator.pop(dialogContext);
              await provider.deleteAlumni(widget.alumniId);
              if (mounted) {
                context.read<AlumniListProvider>().loadAlumni();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alumni deleted successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
                context.pop();
              }
            },
            colors: [AppColors.error, AppColors.error.withValues(alpha: 0.8)],
            height: 44,
            width: 100,
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final List<Color>? colors;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = colors ?? AppColors.cardGradientColors;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors
                .map((c) => c.withValues(alpha: 0.15))
                .toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: gradientColors.first, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: gradientColors.first,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
