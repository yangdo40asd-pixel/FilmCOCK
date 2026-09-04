import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/data/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WatchOptionsSheet extends StatelessWidget {
  final int movieId;
  final String movieTitle;

  const WatchOptionsSheet({
    super.key,
    required this.movieId,
    required this.movieTitle,
  });

  static Future<void> show(
    BuildContext context, {
    required int movieId,
    required String movieTitle,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          WatchOptionsSheet(movieId: movieId, movieTitle: movieTitle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.72,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1B1B1B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white38,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              '어디서 볼까요?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            const TabBar(
              indicatorColor: Color(0xFF7656E8),
              indicatorWeight: 3,
              labelColor: Color(0xFF8B6CFF),
              unselectedLabelColor: Colors.white54,
              tabs: [
                Tab(text: 'OTT'),
                Tab(text: '극장'),
              ],
            ),
            Flexible(
              child: TabBarView(
                children: [
                  _OttProviderTab(movieId: movieId),
                  _TheaterTab(movieTitle: movieTitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OttProviderTab extends StatefulWidget {
  final int movieId;

  const _OttProviderTab({required this.movieId});

  @override
  State<_OttProviderTab> createState() => _OttProviderTabState();
}

class _OttProviderTabState extends State<_OttProviderTab> {
  late Future<List<WatchProvider>> _providers;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  void _loadProviders() {
    _providers = ApiService.getMovieWatchProviders(widget.movieId);
  }

  void _retry() {
    setState(_loadProviders);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WatchProvider>>(
      future: _providers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF7656E8)),
          );
        }

        if (snapshot.hasError) {
          return _SheetMessage(
            message: '시청 정보를 불러오지 못했습니다.',
            actionLabel: '다시 시도',
            onAction: _retry,
          );
        }

        final providers = snapshot.data ?? [];
        if (providers.isEmpty) {
          return const _SheetMessage(message: '현재 국내 OTT 제공 정보가 없습니다.');
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
          itemCount: providers.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 18,
            mainAxisSpacing: 22,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, index) {
            return _ProviderTile(provider: providers[index]);
          },
        );
      },
    );
  }
}

class _ProviderTile extends StatelessWidget {
  final WatchProvider provider;

  const _ProviderTile({required this.provider});

  Future<void> _openWatchLink(BuildContext context) async {
    final uri = Uri.tryParse(provider.link);
    if (uri == null || !await canLaunchUrl(uri)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('서비스 링크를 열 수 없습니다.')));
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('서비스 링크를 열 수 없습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: provider.link.isEmpty ? null : () => _openWatchLink(context),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          SizedBox(
            width: 68,
            height: 68,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: provider.fullLogoUrl.isEmpty
                  ? Container(
                      color: Colors.white12,
                      child: const Icon(Icons.tv, color: Colors.white54),
                    )
                  : Image.network(
                      provider.fullLogoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.white12,
                        child: const Icon(Icons.tv, color: Colors.white54),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.providerName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 3),
          Text(
            provider.offerType,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _TheaterTab extends StatelessWidget {
  final String movieTitle;

  const _TheaterTab({required this.movieTitle});

  @override
  Widget build(BuildContext context) {
    final encodedTitle = Uri.encodeQueryComponent(movieTitle);
    final theaters = [
      _TheaterLink(
        name: 'CGV',
        icon: Icons.local_movies_outlined,
        url: 'https://www.cgv.co.kr/search/?query=$encodedTitle',
      ),
      _TheaterLink(
        name: '롯데시네마',
        icon: Icons.movie_outlined,
        url:
            'https://www.lottecinema.co.kr/NLCHS/Search?searchText=$encodedTitle',
      ),
      _TheaterLink(
        name: '메가박스',
        icon: Icons.theaters_outlined,
        url: 'https://www.megabox.co.kr/movie?searchText=$encodedTitle',
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
      itemCount: theaters.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _TheaterLinkTile(theater: theaters[index]);
      },
    );
  }
}

class _TheaterLink {
  final String name;
  final IconData icon;
  final String url;

  const _TheaterLink({
    required this.name,
    required this.icon,
    required this.url,
  });
}

class _TheaterLinkTile extends StatelessWidget {
  final _TheaterLink theater;

  const _TheaterLinkTile({required this.theater});

  Future<void> _open(BuildContext context) async {
    final uri = Uri.tryParse(theater.url);
    if (uri == null || !await canLaunchUrl(uri)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('극장 사이트를 열 수 없습니다.')));
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('극장 사이트를 열 수 없습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _open(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      tileColor: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF7656E8),
        child: Icon(theater.icon, color: Colors.white),
      ),
      title: Text(
        theater.name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: const Text(
        '영화 검색 후 예매하기',
        style: TextStyle(color: Colors.white54),
      ),
      trailing: const Icon(Icons.open_in_new, color: Colors.white70),
    );
  }
}

class _SheetMessage extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SheetMessage({required this.message, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.movie_outlined, color: Colors.white38, size: 42),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
