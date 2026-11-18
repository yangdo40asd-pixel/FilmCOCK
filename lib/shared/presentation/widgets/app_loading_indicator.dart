import 'package:flutter/material.dart';

class AppLoadingIndicator extends StatelessWidget {
  final String label;
  final Color? color;
  final double strokeWidth;

  const AppLoadingIndicator({
    super.key,
    this.label = '콘텐츠를 불러오는 중입니다.',
    this.color,
    this.strokeWidth = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      liveRegion: true,
      readOnly: true,
      child: ExcludeSemantics(
        child: CircularProgressIndicator(
          color: color ?? Theme.of(context).colorScheme.primary,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}
