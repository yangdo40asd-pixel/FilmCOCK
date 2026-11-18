import 'package:filmcock_app/features/profile/presentation/widgets/watched_calendar_button.dart';
import 'package:filmcock_app/features/profile/presentation/widgets/activity_sections.dart';
import 'package:filmcock_app/features/profile/presentation/widgets/profile_summary_card.dart';
import 'package:filmcock_app/features/activity/domain/activity_tier.dart';
import 'package:flutter/material.dart';
import 'package:filmcock_app/shared/domain/models/catalog_models.dart';
import 'package:filmcock_app/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:filmcock_app/features/person_detail/presentation/screens/actor_detail_screen.dart';
import 'package:filmcock_app/features/person_detail/presentation/screens/artist_detail_screen.dart';
import 'package:filmcock_app/features/movie_detail/presentation/screens/movie_detail_screen.dart';
import 'package:filmcock_app/features/profile/presentation/screens/profile_edit_screen.dart';
import 'package:filmcock_app/features/profile/presentation/screens/settings_screen.dart';
import 'package:filmcock_app/features/activity/data/activity_repository.dart';
import 'package:filmcock_app/features/preferences/data/user_settings_repository.dart';
import 'package:filmcock_app/features/activity/application/activity_change_service.dart';
import 'package:filmcock_app/features/profile/presentation/widgets/my_page_tier_section.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final ActivityRepository _activityRepository = const ActivityRepository();
  final UserSettingsRepository _settingsRepository =
      const UserSettingsRepository();
  String _nickname = '영화 매니아';
  String _bio = '영화와 함께하는 일상!';
  String? _profileImagePath;

  List<Map<String, dynamic>> _watchedMovies = [];
  List<Map<String, dynamic>> _likedMovies = [];
  List<Map<String, dynamic>> _comments = [];
  List<Map<String, dynamic>> _likedPeople = [];
  bool _isLoading = true;
  int _loadId = 0;

  @override
  void initState() {
    super.initState();
    ActivityChangeService.revision.addListener(_handleActivityChange);
    _loadUserData();
  }

  @override
  void dispose() {
    ActivityChangeService.revision.removeListener(_handleActivityChange);
    super.dispose();
  }

  void _handleActivityChange() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final loadId = ++_loadId;
    final loaded = await Future.wait<Object>([
      _settingsRepository.loadProfile(),
      _activityRepository.watchedMovies(),
      _activityRepository.likedMovies(),
      _activityRepository.comments(),
      _activityRepository.likedPeople(),
    ]);
    final profile = loaded[0] as UserProfileData;
    final watched = loaded[1] as List<Map<String, dynamic>>;
    final liked = loaded[2] as List<Map<String, dynamic>>;
    final comments = loaded[3] as List<Map<String, dynamic>>;
    final people = loaded[4] as List<Map<String, dynamic>>;

    if (mounted && loadId == _loadId) {
      setState(() {
        _nickname = profile.nickname;
        _bio = profile.bio;
        _profileImagePath = profile.imagePath;
        _watchedMovies = watched;
        _likedMovies = liked;
        _comments = comments;
        _likedPeople = people;
        _isLoading = false;
      });
    }
  }

  ActivityTier get _tier => ActivityTier(
    watchedCount: _watchedMovies.length,
    commentCount: _comments.length,
  );
  int get _currentTierLevel => _tier.level;
  String get _tierProgressText => _tier.progressText;

  void _showCalendarGuideDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        title: Text(
          '캘린더 이용 안내',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '봤어요! 버튼을 눌러 작품을 추가해보세요.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
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
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFA88BFA)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          '마이페이지',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: '설정 열기',
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
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 프로필 정보 카드
              _buildProfileCard(),

              // 2. 등급 배너 ("영화를 많이 볼수록 등급이 오릅니다!")
              MyPageTierSection(
                currentTier: _currentTierLevel,
                progressText: _tierProgressText,
              ),

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
  Widget _buildProfileCard() => ProfileSummaryCard(
    nickname: _nickname,
    bio: _bio,
    imagePath: _profileImagePath,
    onEdit: () async {
      final updated = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
      );
      if (mounted && updated == true) _loadUserData();
    },
  );

  Widget _buildCalendarButton() =>
      WatchedCalendarButton(onTap: _showCalendarGuideDialog);

  // 4. 내가 추천한 띵작! (오직 좋아요 누른 영화만 연동)
  void _openMovie(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
    ).then((_) {
      if (mounted) _loadUserData();
    });
  }

  void _openPerson(Map<String, dynamic> person) {
    final id = int.tryParse(person['id'].toString()) ?? 0;
    final name = person['name'] as String? ?? '인물';
    final profile = person['profileUrl'] as String? ?? '';
    final fullProfile =
        profile.isEmpty ||
            profile.startsWith('http://') ||
            profile.startsWith('https://')
        ? profile
        : 'https://image.tmdb.org/t/p/w500${profile.startsWith('/') ? profile : '/$profile'}';
    final Widget screen = person['department'] == '배우'
        ? ActorDetailScreen(
            actor: Person(
              id: id,
              name: name,
              knownForDepartment: 'Acting',
              profilePath: profile.isEmpty
                  ? null
                  : profile.replaceFirst('https://image.tmdb.org/t/p/w500', ''),
            ),
          )
        : ArtistDetailScreen(
            artistId: id,
            artistName: name,
            profileUrl: fullProfile,
          );
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen)).then((
      _,
    ) {
      if (mounted) _loadUserData();
    });
  }

  Widget _buildRecommendedMoviesSection() =>
      RecommendedMoviesSection(movies: _likedMovies, onMovieTap: _openMovie);
  Widget _buildLikedPeopleSection() =>
      LikedPeopleSection(people: _likedPeople, onPersonTap: _openPerson);
  Widget _buildMyCommentsSection() =>
      MyCommentsSection(comments: _comments, onMovieTap: _openMovie);
}
