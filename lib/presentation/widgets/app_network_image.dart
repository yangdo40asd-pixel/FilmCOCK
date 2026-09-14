import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final IconData placeholderIcon;
  final double placeholderIconSize;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholderIcon = Icons.movie_outlined,
    this.placeholderIconSize = 36,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = _ImagePlaceholder(
      width: width,
      height: height,
      icon: placeholderIcon,
      iconSize: placeholderIconSize,
    );

    if (imageUrl.trim().isEmpty) return placeholder;

    return Image.network(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final IconData icon;
  final double iconSize;

  const _ImagePlaceholder({
    required this.width,
    required this.height,
    required this.icon,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      color: colors.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize, color: colors.onSurfaceVariant),
    );
  }
}
