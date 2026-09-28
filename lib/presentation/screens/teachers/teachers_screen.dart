import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/network_photo.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/models/teacher.dart';
import '../../providers/teachers_provider.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  String? _designation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Always refresh once per session; cached data shows in the meantime.
      final provider = context.read<TeachersProvider>();
      if (!provider.isLoading) provider.load();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Teacher> _visible(List<Teacher> all) {
    final q = _query.trim().toLowerCase();
    return all.where((t) {
      if (_designation != null && t.designation != _designation) return false;
      return q.isEmpty ||
          t.name.toLowerCase().contains(q) ||
          t.designation.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeachersProvider>();
    final all = provider.teachers;
    final visible = _visible(all);
    final leaders = [provider.principal, provider.assistantHead].nonNulls;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: provider.load,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  sliver: SliverList.list(
                    children: [
                      PageTitle(
                        subtitle: all.isEmpty
                            ? 'Faculty'
                            : '${all.length} teachers',
                        title: 'Teachers',
                      ),
                      const SizedBox(height: 20),
                      if (leaders.isNotEmpty) ...[
                        _LeaderCard(
                          teacher: leaders.first,
                          onTap: () => _showTeacher(leaders.first),
                        ),
                        for (final leader in leaders.skip(1)) ...[
                          const SizedBox(height: 12),
                          _LeaderRow(
                            teacher: leader,
                            onTap: () => _showTeacher(leader),
                          ),
                        ],
                        const SizedBox(height: 28),
                      ],
                      if (all.isNotEmpty) ...[
                        const SectionHeader(title: 'Our Faculty'),
                        const SizedBox(height: 12),
                        _SearchField(
                          controller: _search,
                          onChanged: (v) => setState(() => _query = v),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _Pill(
                                label: 'All',
                                selected: _designation == null,
                                onTap: () =>
                                    setState(() => _designation = null),
                              ),
                              for (final d in provider.designations)
                                _Pill(
                                  label: d,
                                  selected: _designation == d,
                                  onTap: () => setState(() => _designation = d),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
                ..._buildGrid(provider, visible),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGrid(TeachersProvider provider, List<Teacher> visible) {
    Widget fill(Widget child) => SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(padding: const EdgeInsets.all(24), child: child),
    );

    if (provider.teachers.isEmpty) {
      if (provider.isLoading) {
        return [
          fill(
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
        ];
      }
      return [
        fill(
          _Message(
            icon: Icons.cloud_off_rounded,
            title: 'Teachers unavailable',
            body: provider.hasError
                ? '${provider.error} Check your connection and try again.'
                : 'No teachers found.',
            action: InkPillButton(label: 'Try Again', onPressed: provider.load),
          ),
        ),
      ];
    }

    if (visible.isEmpty) {
      return [
        fill(
          const _Message(
            icon: Icons.search_off_rounded,
            title: 'No matches',
            body: 'Try a different name or designation.',
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid.builder(
          itemCount: visible.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            final teacher = visible[index];
            return _TeacherTile(
              teacher: teacher,
              onTap: () => _showTeacher(teacher),
            ).animate().fadeIn(delay: (25 * (index % 12)).ms, duration: 300.ms);
          },
        ),
      ),
    ];
  }

  void _showTeacher(Teacher teacher) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (context) => _TeacherSheet(teacher: teacher),
    );
  }
}

/// Initials on a warm gradient, shown when a teacher has no photo.
class _InitialsPhoto extends StatelessWidget {
  final String name;
  final double fontSize;

  const _InitialsPhoto({required this.name, this.fontSize = 28});

  @override
  Widget build(BuildContext context) {
    final parts = name
        .split(RegExp(r'[\s.]+'))
        .where((p) => p.isNotEmpty && p.toLowerCase() != 'md')
        .toList();
    final initials = parts.take(2).map((p) => p[0].toUpperCase()).join();

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.secondaryGradient),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// E-card for the principal.
class _LeaderCard extends StatelessWidget {
  final Teacher teacher;
  final VoidCallback onTap;

  const _LeaderCard({required this.teacher, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1.75,
        child: EmberBackground(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                right: 22,
                top: 20,
                child: Text(
                  'AUSC',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const Positioned(
                left: 22,
                top: 22,
                child: TagChip(label: 'Head of Institution', onDark: true),
              ),
              Positioned(
                left: 22,
                right: 22,
                bottom: 22,
                child: Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: NetworkPhoto(
                          url: teacher.photoUrl,
                          placeholder: _InitialsPhoto(
                            name: teacher.name,
                            fontSize: 22,
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
                            teacher.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            teacher.designation,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  final Teacher teacher;
  final VoidCallback onTap;

  const _LeaderRow({required this.teacher, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SoftCard(
      radius: 26,
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: 58,
              height: 58,
              child: NetworkPhoto(
                url: teacher.photoUrl,
                placeholder: _InitialsPhoto(name: teacher.name, fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TagChip(label: teacher.designation),
                const SizedBox(height: 6),
                Text(
                  teacher.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: textTheme.bodySmall?.color),
        ],
      ),
    );
  }
}

class _TeacherTile extends StatelessWidget {
  final Teacher teacher;
  final VoidCallback onTap;

  const _TeacherTile({required this.teacher, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SoftCard(
      radius: 26,
      padding: const EdgeInsets.all(8),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: double.infinity,
                child: NetworkPhoto(
                  url: teacher.photoUrl,
                  placeholder: _InitialsPhoto(name: teacher.name),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher.name,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  teacher.designation,
                  style: textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherSheet extends StatelessWidget {
  final Teacher teacher;

  const _TeacherSheet({required this.teacher});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: SizedBox(
                width: 160,
                height: 190,
                child: NetworkPhoto(
                  url: teacher.photoUrl,
                  placeholder: _InitialsPhoto(name: teacher.name, fontSize: 44),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              teacher.name,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TagChip(label: teacher.designation),
            const SizedBox(height: 24),
            InkPillButton(
              label: 'View on school website',
              icon: Icons.north_east_rounded,
              expand: true,
              onPressed: () => launchUrl(
                Uri.parse(teacher.profileUrl),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(100),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search teachers…',
          filled: false,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
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
}

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Pill({
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

class _Message extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  const _Message({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
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
          Text(body, style: textTheme.bodyMedium, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 22), action!],
        ],
      ),
    );
  }
}
