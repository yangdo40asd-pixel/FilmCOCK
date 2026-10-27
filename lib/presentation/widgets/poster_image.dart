import 'package:flutter/material.dart';

import 'app_network_image.dart';

/// TMDB 포스터 원본 비율(2:3)을 유지해 잘림 없이 보여주는 공용 포스터 위젯.
class PosterImage extends StatelessWidget {
  static const double aspectRatio = 2 / 3;

  final String imageUrl;
  final double width;
  final BorderRadius borderRadius;

  const PosterImage({
    super.key,
    required this.imageUrl,
    required this.width,
    this.borderRadius = BorderRadius.zero,
  });

  double get height => width / aspectRatio;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: AppNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          placeholderIconSize: width * 0.25,
        ),
      ),
    );
  }
}
