import 'package:flutter/material.dart';
import 'vowora_cached_image.dart';

class ConferenceProviderImage extends StatelessWidget {
  const ConferenceProviderImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderIcon = Icons.image_not_supported_outlined,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    if (url.isEmpty) return _placeholder();

    return VoworaCachedImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      contextSize: ImageContextSize.card,
      errorWidget: _placeholder(),
    );
  }

  Widget _placeholder() => Container(
    width: width,
    height: height,
    color: const Color(0xFFF0E6DD),
    alignment: Alignment.center,
    child: Icon(placeholderIcon, color: const Color(0xFFB88A68), size: 32),
  );
}
