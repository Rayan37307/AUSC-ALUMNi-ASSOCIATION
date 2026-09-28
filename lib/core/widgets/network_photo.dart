import 'package:flutter/material.dart';

/// Remote photo that also works on web when the host sends no CORS headers
/// (falls back to an HTML <img> element), with a placeholder while loading
/// and on failure.
class NetworkPhoto extends StatelessWidget {
  final String? url;
  final Widget placeholder;
  final BoxFit fit;
  final Alignment alignment;

  const NetworkPhoto({
    super.key,
    required this.url,
    required this.placeholder,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    final src = url;
    if (src == null) return placeholder;

    return Image.network(
      src,
      fit: fit,
      alignment: alignment,
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : placeholder,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}
