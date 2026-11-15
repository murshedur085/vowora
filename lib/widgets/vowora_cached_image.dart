import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum ImageContextSize { thumbnail, card, hero, full }

class VoworaCachedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final ImageContextSize contextSize;
  final String? cacheKey;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool isAssetFallback;

  const VoworaCachedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.contextSize = ImageContextSize.card,
    this.cacheKey,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.isAssetFallback = false,
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrl = imageUrl.trim();

    Widget content;

    if (cleanUrl.isEmpty) {
      content = _buildErrorWidget(context);
    } else if (cleanUrl.startsWith('assets/')) {
      content = Image.asset(
        cleanUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (c, e, s) => _buildErrorWidget(context),
      );
    } else if (!cleanUrl.startsWith('http')) {
      content = _buildErrorWidget(context);
    } else if (kIsWeb) {
      // Direct native browser image rendering on Web to avoid XHR CORS restrictions
      content = Image.network(
        cleanUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? _buildSkeletonPlaceholder(context);
        },
        errorBuilder: (c, e, s) => errorWidget ?? _buildErrorWidget(context),
      );
    } else {
      // Mobile / Desktop cached network rendering
      content = CachedNetworkImage(
        imageUrl: cleanUrl,
        cacheKey: cacheKey,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (context, url) => placeholder ?? _buildSkeletonPlaceholder(context),
        errorWidget: (context, url, error) => Image.network(
          cleanUrl,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (c, e, s) => errorWidget ?? _buildErrorWidget(context),
        ),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildSkeletonPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF4EFE5),
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB89B5E)),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF4EFE5),
        borderRadius: borderRadius,
        border: Border.all(color: const Color(0xFFEAE7E1)),
      ),
      child: const Center(
        child: Icon(
          Icons.photo_rounded,
          color: Color(0xFFB89B5E),
          size: 28,
        ),
      ),
    );
  }
}

class VoworaImagePreloader {
  /// Preloads essential image URLs into cache asynchronously without blocking UI thread
  static void preloadImages(BuildContext context, List<String> imageUrls) {
    if (imageUrls.isEmpty) return;
    Future.microtask(() {
      if (!context.mounted) return;
      for (final url in imageUrls) {
        final clean = url.trim();
        if (!context.mounted) break;
        if (clean.startsWith('http')) {
          precacheImage(
            CachedNetworkImageProvider(clean),
            context,
            onError: (exception, stackTrace) {},
          );
        } else if (clean.startsWith('assets/')) {
          precacheImage(
            AssetImage(clean),
            context,
            onError: (exception, stackTrace) {},
          );
        }
      }
    });
  }
}
