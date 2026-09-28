import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ui_kit.dart';
import '../../../../data/content/school_content.dart';

/// Auto-advancing banner of school photos with page indicators.
class BannerCarousel extends StatefulWidget {
  final List<BannerSlide> slides;
  final Duration interval;

  const BannerCarousel({
    super.key,
    required this.slides,
    this.interval = const Duration(seconds: 4),
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.slides.length < 2) return;
    _timer = Timer.periodic(widget.interval, (_) {
      if (!_controller.hasClients) return;
      final next = (_page + 1) % widget.slides.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 2,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // Restart the countdown whenever the user swipes manually.
              if (notification is ScrollStartNotification &&
                  notification.dragDetails != null) {
                _timer?.cancel();
              } else if (notification is ScrollEndNotification) {
                _startTimer();
              }
              return false;
            },
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.slides.length,
              onPageChanged: (index) => setState(() => _page = index),
              itemBuilder: (context, index) =>
                  _BannerSlideView(slide: widget.slides[index]),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.slides.length, (index) {
            final active = index == _page;
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primary
                    : (isDark ? Colors.white24 : Colors.black12),
                borderRadius: BorderRadius.circular(100),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BannerSlideView extends StatelessWidget {
  final BannerSlide slide;

  const _BannerSlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    final image = slide.image;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: image == null
          ? EmberBackground(child: _caption(context, withIcon: true))
          : ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const EmberBackground(),
                  ),
                  if (slide.showCaption) ...[
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xB3000000)],
                          stops: [0.35, 1],
                        ),
                      ),
                    ),
                    _caption(context),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _caption(BuildContext context, {bool withIcon = false}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (withIcon)
          Positioned(
            right: -18,
            bottom: -24,
            child: Icon(
              slide.icon,
              size: 150,
              color: Colors.white.withValues(alpha: 0.16),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const TagChip(label: SchoolContent.shortName, onDark: true),
              const SizedBox(height: 10),
              Text(
                slide.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                slide.subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
