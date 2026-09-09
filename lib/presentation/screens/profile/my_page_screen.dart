import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/presentation/screens/calendar/calendar_screen.dart';
import 'package:filmcock_app/presentation/screens/detail/actor_detail_screen.dart';
import 'package:filmcock_app/presentation/screens/detail/artist_detail_screen.dart';
import 'package:filmcock_app/presentation/screens/detail/movie_detail_screen.dart';
import 'package:filmcock_app/presentation/screens/profile/profile_edit_screen.dart';
import 'package:filmcock_app/presentation/screens/profile/settings_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  String _nickname = '영화 매니아';
  String _bio = '영화와 함께하는 일상!';
  String? _profileImagePath;

  List<Map<String, dynamic>> _watchedMovies = [];
  List<Map<String, dynamic>> _likedMovies = [];
  List<Map<String, dynamic>> _comments = [];
  List<Map<String, dynamic>> _likedPeople = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Profile
    final nickname = prefs.getString('user_nickname') ?? '영화 매니아';
    final bio = prefs.getString('user_bio') ?? '영화와 함께하는 일상!';
    final profileImg = prefs.getString('user_profile_image');

    // 2. Watched & Liked Movies (Filter out any dummy data)
    final rawWatched = prefs.getStringList('watched_movies_data') ?? [];
    final watched = _parseJsonList(rawWatched)
        .where((m) =>
            m['title'] != '인터스텔라' &&
            m['title'] != '인셉션' &&
            m['title'] != '기생충')
        .toList();

    final rawLiked = prefs.getStringList('liked_movies_data') ?? [];
    final liked = _parseJsonList(rawLiked)
        .where((m) =>
            m['title'] != '인터스텔라' &&
            m['title'] != '인셉션' &&
            m['title'] != '기생충')
        .toList();

    // 3. Comments (Filter out any dummy comments)
    final rawComments = prefs.getStringList('user_comments') ?? [];
    final comments = _parseJsonList(rawComments)
        .where((m) =>
            m['movieTitle'] != '반지의 제왕: 왕의 귀환' &&
            m['movieTitle'] != '레지던트 이블')
        .toList();

    // 4. Liked People (Filter out any dummy people)
    final rawPeople = prefs.getStringList('liked_people') ?? [];
    final people = _parseJsonList(rawPeople)
        .where((p) =>
            p['name'] != '봉준호' &&
            p['name'] != '송강호' &&
            p['name'] != '박찬욱')
        .toList();

    // Persist cleaned data to purge dummy items from storage
    await prefs.setStringList(
      'watched_movies_data',
      watched.map((e) => jsonEncode(e)).toList(),
    );
    await prefs.setStringList(
      'liked_movies_data',
      liked.map((e) => jsonEncode(e)).toList(),
    );
    await prefs.setStringList(
      'user_comments',
      comments.map((e) => jsonEncode(e)).toList(),
    );
    await prefs.setStringList(
      'liked_people',
      people.map((e) => jsonEncode(e)).toList(),
    );

    if (mounted) {
      setState(() {
        _nickname = nickname;
        _bio = bio;
        _profileImagePath = profileImg;
        _watchedMovies = watched;
        _likedMovies = liked;
        _comments = comments;
        _likedPeople = people;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _parseJsonList(List<String> list) {
    return list.map((e) {
      try {
        return jsonDecode(e) as Map<String, dynamic>;
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((m) => m.isNotEmpty).toList();
  }

  String _getFullImageUrl(String? path, {bool isPerson = false}) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final size = isPerson ? 'w500' : 'w300';
    return 'https://image.tmdb.org/t/p/$size$cleanPath';
  }

  int get _totalActions => _watchedMovies.length + _comments.length;

  int get _currentTierLevel {
    if (_totalActions >= 15) return 3; // 초고수
    if (_totalActions >= 5) return 2;  // 고수
    return 1;                          // 초심자
  }

  String get _tierProgressText {
    if (_totalActions >= 15) {
      return '최고 등급인 초고수에 도달했습니다! 🎉';
    }
    final remaining = 15 - _totalActions;
    return '초고수까지 영화 $remaining편 또는 댓글 $remaining개 남았어요!';
  }

  void _showCalendarGuideDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF282830),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        title: const Text(
          '캘린더 이용 안내',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '봤어요! 버튼을 눌러 작품을 추가해보세요.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CalendarScreen(),
                ),
              ).then((_) => _loadUserData());
            },
            child: const Text(
              '확인',
              style: TextStyle(
                color: Color(0xFFA88BFA),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF141414),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFA88BFA)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        title: const Text(
          '마이페이지',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        color: const Color(0xFFA88BFA),
        backgroundColor: const Color(0xFF222222),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 프로필 정보 카드
              _buildProfileCard(),

              // 2. 등급 배너 ("영화를 많이 볼수록 등급이 오릅니다!")
              _buildTierSection(),

              // 3. 본 작품 캘린더 버튼
              _buildCalendarButton(),

              const SizedBox(height: 16),

              // 4. 내가 추천한 띵작! (오직 좋아요 누른 영화만 연동)
              _buildRecommendedMoviesSection(),

              const SizedBox(height: 24),

              // 5. 좋아요한 인물
              _buildLikedPeopleSection(),

              const SizedBox(height: 24),

              // 6. 내가 쓴 댓글
              _buildMyCommentsSection(),
            ],
          ),
        ),
      ),
    );
  }

  // 1. 프로필 영역
  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E22),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          // Circular Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: ClipOval(
              child: (_profileImagePath != null &&
                      _profileImagePath!.isNotEmpty &&
                      File(_profileImagePath!).existsSync())
                  ? Image.file(
                      File(_profileImagePath!),
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/popcorn_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, stack) => const Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          // Name & Bio
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nickname,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _bio,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Edit Profile Button
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
              );
              if (updated == true) {
                _loadUserData();
              }
            },
            child: const Text(
              '프로필 수정',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // 2. 등급 배너 ("영화를 많이 볼수록 등급이 오릅니다!")
  Widget _buildTierSection() {
    final currentTier = _currentTierLevel;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E22),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '영화를 많이 볼수록 등급이 오릅니다!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTierBadge(
                title: '초심자',
                imagePath: 'assets/images/tier/tier_beginner.png',
                isUnlocked: currentTier >= 1,
                isCurrent: currentTier == 1,
              ),
              Expanded(
                child: Container(
                  height: 3,
                  color: currentTier >= 2
                      ? const Color(0xFF8B5CF6)
                      : Colors.white12,
                ),
              ),
              _buildTierBadge(
                title: '고수',
                imagePath: 'assets/images/tier/tier_master.png',
                isUnlocked: currentTier >= 2,
                isCurrent: currentTier == 2,
              ),
              Expanded(
                child: Container(
                  height: 3,
                  color: currentTier >= 3
                      ? const Color(0xFF8B5CF6)
                      : Colors.white12,
                ),
              ),
              _buildTierBadge(
                title: '초고수',
                imagePath: 'assets/images/tier/tier_grandmaster.jpeg',
                isUnlocked: currentTier >= 3,
                isCurrent: currentTier == 3,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              _tierProgressText,
              style: const TextStyle(
                color: Color(0xFFA88BFA),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierBadge({
    required String title,
    required String imagePath,
    required bool isUnlocked,
    required bool isCurrent,
  }) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: const Color(0xFFA88BFA), width: 2.5)
                : null,
          ),
          child: ClipOval(
            child: Opacity(
              opacity: isUnlocked ? 1.0 : 0.35,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Icon(
                  Icons.military_tech,
                  size: 36,
                  color: isUnlocked ? const Color(0xFF8B5CF6) : Colors.grey,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            color: isUnlocked ? Colors.white : Colors.grey[600],
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // 3. 본 작품 캘린더 버튼
  Widget _buildCalendarButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: _showCalendarGuideDialog,
          child: const Center(
            child: Text(
              '📅  본 작품 캘린더',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 4. 내가 추천한 띵작! (오직 좋아요 누른 영화만 연동)
  Widget _buildRecommendedMoviesSection() {
    // Deduplicate by ID
    final seen = <String>{};
    final uniqueMovies = <Map<String, dynamic>>[];
    for (final m in _likedMovies) {
      final id = m['id'].toString();
      if (!seen.contains(id)) {
        seen.add(id);
        uniqueMovies.add(m);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            '🍿 내가 추천한 띵작!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (uniqueMovies.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Text(
              '영화 상세에서 "좋아요(하트)"를 누르면 여기에 추천 띵작으로 등록됩니다.',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          )
        else
          SizedBox(
            height: 175,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: uniqueMovies.length,
              itemBuilder: (context, index) {
                final movie = uniqueMovies[index];
                final posterPath = movie['posterPath'] as String?;
                final title = movie['title'] as String? ?? '영화 제목';
                final voteAverage = (movie['voteAverage'] as num?)?.toDouble() ?? 8.0;
                final fullPosterUrl = _getFullImageUrl(posterPath);

                return GestureDetector(
                  onTap: () {
                    final movieObj = Movie(
                      id: int.tryParse(movie['id'].toString()) ?? 0,
                      title: title,
                      overview: '',
                      posterPath: posterPath,
                      voteAverage: voteAverage,
                      releaseDate: '',
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailScreen(movie: movieObj),
                      ),
                    ).then((_) => _loadUserData());
                  },
                  child: Container(
                    width: 105,
                    margin: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: fullPosterUrl.isNotEmpty
                              ? Image.network(
                                  fullPosterUrl,
                                  width: 105,
                                  height: 135,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) =>
                                      Container(
                                    width: 105,
                                    height: 135,
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.movie,
                                      color: Colors.white54,
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 105,
                                  height: 135,
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.movie,
                                    color: Colors.white54,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // 5. 좋아요한 인물
  Widget _buildLikedPeopleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            '💖 좋아요한 인물',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_likedPeople.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Text(
              '좋아하는 배우나 감독의 상세 페이지에서 하트를 눌러보세요!',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          )
        else
          SizedBox(
            height: 105,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _likedPeople.length,
              itemBuilder: (context, index) {
                final person = _likedPeople[index];
                final name = person['name'] as String? ?? '인물';
                final profileUrl = person['profileUrl'] as String? ?? '';
                final isActor = person['department'] == '배우';
                final fullProfileUrl = _getFullImageUrl(profileUrl, isPerson: true);

                return GestureDetector(
                  onTap: () {
                    final personId = int.tryParse(person['id'].toString()) ?? 0;
                    if (isActor) {
                      final pObj = Person(
                        id: personId,
                        name: name,
                        knownForDepartment: 'Acting',
                        profilePath: profileUrl.isNotEmpty
                            ? profileUrl.replaceFirst('https://image.tmdb.org/t/p/w500', '')
                            : null,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ActorDetailScreen(actor: pObj),
                        ),
                      ).then((_) => _loadUserData());
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArtistDetailScreen(
                            artistId: personId,
                            artistName: name,
                            profileUrl: fullProfileUrl,
                          ),
                        ),
                      ).then((_) => _loadUserData());
                    }
                  },
                  child: Container(
                    width: 78,
                    margin: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: const Color(0xFF2C2C2E),
                          backgroundImage: fullProfileUrl.isNotEmpty
                              ? NetworkImage(fullProfileUrl)
                              : null,
                          child: fullProfileUrl.isEmpty
                              ? const Icon(Icons.person, color: Colors.white70)
                              : null,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // 6. 내가 쓴 댓글
  Widget _buildMyCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📝 내가 쓴 댓글',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_comments.length}개',
                style: const TextStyle(
                  color: Color(0xFFA88BFA),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_comments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Text(
              '아직 작성한 댓글이 없습니다. 영화 상세화면에서 댓글을 남겨보세요!',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              final item = _comments[index];
              final movieTitle = item['movieTitle'] as String? ?? '영화 제목';
              final posterPath = item['posterPath'] as String?;
              final content = item['content'] as String? ?? '';
              final date = item['date'] as String? ?? '';
              final movieId = int.tryParse(item['movieId'].toString()) ?? 0;
              final fullPosterUrl = _getFullImageUrl(posterPath);

              return GestureDetector(
                onTap: () {
                  if (movieId > 0) {
                    final movieObj = Movie(
                      id: movieId,
                      title: movieTitle,
                      overview: '',
                      posterPath: posterPath,
                      voteAverage: 8.0,
                      releaseDate: '',
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailScreen(movie: movieObj),
                      ),
                    ).then((_) => _loadUserData());
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E22),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: fullPosterUrl.isNotEmpty
                            ? Image.network(
                                fullPosterUrl,
                                width: 52,
                                height: 74,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) =>
                                    Container(
                                  width: 52,
                                  height: 74,
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.movie,
                                    color: Colors.white54,
                                    size: 28,
                                  ),
                                ),
                              )
                            : Container(
                                width: 52,
                                height: 74,
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.movie,
                                  color: Colors.white54,
                                  size: 28,
                                ),
                              ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    movieTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (date.isNotEmpty)
                                  Text(
                                    date,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              content,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
