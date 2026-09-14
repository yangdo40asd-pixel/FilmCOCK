import 'package:flutter/material.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ReviewChannelsSection extends StatelessWidget {
  const ReviewChannelsSection({super.key});

  static final List<ReviewChannel> _channels = [
    ReviewChannel(
      name: '단군',
      logoAsset: 'assets/images/dangun.png',
      youtubeUrl: 'https://www.youtube.com/@kimdangun',
    ),
    ReviewChannel(
      name: '리뷰마스터',
      logoAsset: 'assets/images/review_master.jpg',
      youtubeUrl: 'https://www.youtube.com/@review.master',
    ),
    ReviewChannel(
      name: '지무비',
      logoAsset: 'assets/images/gmovie.webp',
      youtubeUrl: 'https://www.youtube.com/@gmovie',
    ),
    ReviewChannel(
      name: '고몽',
      logoAsset: 'assets/images/gomong.png',
      youtubeUrl: 'https://www.youtube.com/@gomong',
    ),
    ReviewChannel(
      name: '김시선',
      logoAsset: 'assets/images/siseon.webp',
      youtubeUrl: 'https://www.youtube.com/@siseon',
    ),
    ReviewChannel(
      name: '달빛뮤즈',
      logoAsset: 'assets/images/moonlightmuse.webp',
      youtubeUrl: 'https://www.youtube.com/@moonlightmuse',
    ),
    ReviewChannel(
      name: '삐맨',
      logoAsset: 'assets/images/bman.webp',
      youtubeUrl: 'https://www.youtube.com/@BMan',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final fallbackColors = <Color>[
      Colors.deepOrange,
      Colors.amber,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.teal,
    ];
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _channels.length,
        itemBuilder: (context, index) {
          final channel = _channels[index];
          final fallbackColor = fallbackColors[index % fallbackColors.length];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _openUrl(context, channel.youtubeUrl),
              child: SizedBox(
                width: 90,
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          channel.logoAsset!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) =>
                              _fallback(fallbackColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      channel.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _fallback(Color color) => Container(
    width: double.infinity,
    color: color,
    child: const Center(
      child: Icon(Icons.play_circle_fill, size: 40, color: Colors.white54),
    ),
  );
}

class KoficBanner extends StatelessWidget {
  const KoficBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => _openUrl(context, 'https://www.kobis.or.kr'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF282932) : colors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.onSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.movie_creation_outlined,
                  color: colors.onSurfaceVariant,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'KOFIC',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '영화진흥위원회',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                color: colors.onSurfaceVariant,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _openUrl(BuildContext context, String value) async {
  final uri = Uri.parse(value);
  try {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) await launchUrl(uri, mode: LaunchMode.platformDefault);
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('외부 링크를 열지 못했습니다.')));
  }
}
