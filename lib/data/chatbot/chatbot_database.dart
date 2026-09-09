import 'package:filmcock_app/data/models/movie_model.dart';

class ChatbotPrompt {
  final String id;
  final String label;
  final String category;
  final String queryText;

  const ChatbotPrompt({
    required this.id,
    required this.label,
    required this.category,
    required this.queryText,
  });
}

class ChatbotMovieData {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final double voteAverage;
  final String releaseDate;
  final String reason;
  final List<String> tags;
  final List<String> categories;

  const ChatbotMovieData({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.reason,
    required this.tags,
    required this.categories,
  });

  Movie toMovie() {
    return Movie(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      voteAverage: voteAverage,
      releaseDate: releaseDate,
    );
  }
}

class ChatbotDatabase {
  // 18종 이상의 세분화된 텍스트 추천 질문 칩 (이모티콘 일체 배제)
  static const List<ChatbotPrompt> promptChips = [
    // 카테고리: 기분 (꼬리질문 연계)
    ChatbotPrompt(
      id: 'mood_down',
      label: '기분이 별로일 때 맞춤 추천',
      category: '기분',
      queryText: '나 오늘 기분이 별로야 맞춤영화를 추천해줘',
    ),
    ChatbotPrompt(
      id: 'mood_healing',
      label: '지치고 피곤할 때 따뜻한 힐링',
      category: '기분',
      queryText: '지치고 피곤해서 따뜻한 힐링이 필요해',
    ),
    ChatbotPrompt(
      id: 'mood_stress',
      label: '스트레스 싹 날릴 사이다 영화',
      category: '기분',
      queryText: '스트레스 싹 날릴 시원한 사이다 영화 추천해줘',
    ),
    ChatbotPrompt(
      id: 'mood_romance',
      label: '마음이 몽글몽글 설레는 영화',
      category: '기분',
      queryText: '마음이 몽글몽글 설레고 연애 세포 깨우는 영화',
    ),
    ChatbotPrompt(
      id: 'mood_crying',
      label: '혼자 펑펑 울고 싶을 때',
      category: '기분',
      queryText: '혼자 펑펑 울면서 감정 쏟아내고 싶어',
    ),

    // 카테고리: 상황
    ChatbotPrompt(
      id: 'sit_beer',
      label: '혼자 캔맥주 마시며 볼 영화',
      category: '상황',
      queryText: '오늘 밤 혼자 캔맥주 마시며 볼 영화 추천해줘',
    ),
    ChatbotPrompt(
      id: 'sit_weekend',
      label: '주말 시간 순삭 몰입작',
      category: '상황',
      queryText: '주말에 시간 순삭되는 몰입도 높은 영화 알려줘',
    ),
    ChatbotPrompt(
      id: 'sit_date',
      label: '연인과 함께 볼 데이트 영화',
      category: '상황',
      queryText: '연인과 함께 볼 달달하고 센스 있는 데이트 영화',
    ),
    ChatbotPrompt(
      id: 'sit_family',
      label: '가족과 다 함께 볼 훈훈한 영화',
      category: '상황',
      queryText: '가족과 다 함께 둘러앉아 볼 훈훈한 영화 추천해줘',
    ),
    ChatbotPrompt(
      id: 'sit_midnight',
      label: '새벽 감성에 젖어드는 심야 영화',
      category: '상황',
      queryText: '새벽 감성에 푹 젖어들기 좋은 심야 영화',
    ),

    // 카테고리: 테마
    ChatbotPrompt(
      id: 'theme_twist',
      label: '결말에 뒤통수 얼얼한 반전 스릴러',
      category: '테마',
      queryText: '결말에 뒤통수 얼얼한 충격 반전 스릴러 알려줘',
    ),
    ChatbotPrompt(
      id: 'theme_art',
      label: '영상미와 음악이 환상적인 명작',
      category: '테마',
      queryText: '영상미와 음악이 환상적인 예술 영화 추천해줘',
    ),
    ChatbotPrompt(
      id: 'theme_masterpiece',
      label: '생각할 거리를 던져주는 인생 영화',
      category: '테마',
      queryText: '생각할 거리를 던져주는 인생 명작 영화 알려줘',
    ),
    ChatbotPrompt(
      id: 'theme_rain',
      label: '비 오는 날 불 끄고 볼 미스터리',
      category: '테마',
      queryText: '비 오는 날 방에서 불 끄고 볼 미스터리 영화',
    ),
    ChatbotPrompt(
      id: 'theme_sf',
      label: '스케일 웅장한 SF 판타지',
      category: '테마',
      queryText: '가슴 웅장해지는 스케일의 SF 판타지 영화 추천해줘',
    ),
    ChatbotPrompt(
      id: 'theme_comedy',
      label: '배꼽 빠지게 웃긴 한국 코미디',
      category: '테마',
      queryText: '배꼽 빠지게 웃긴 한국 코미디 영화 알려줘',
    ),

    // 카테고리: MBTI 및 특화
    ChatbotPrompt(
      id: 'mbti_custom',
      label: '내 MBTI 맞춤 영화 추천',
      category: 'MBTI',
      queryText: '내 MBTI 성향에 딱 맞는 추천 영화는 무엇인가요?',
    ),
    ChatbotPrompt(
      id: 'hot_boxoffice',
      label: '요즘 평가 가장 좋은 핫한 영화',
      category: 'MBTI',
      queryText: '요즘 박스오피스에서 가장 평가 좋은 영화 추천해줘',
    ),
    ChatbotPrompt(
      id: 'verified_high',
      label: '평점 8.5점 이상 실패 없는 명작',
      category: 'MBTI',
      queryText: '평점 8.5점 이상 검증된 실패 없는 명작 추천해줘',
    ),
  ];

  // 정교하게 큐레이션된 영화 데이터베이스
  static const List<ChatbotMovieData> curatedMovies = [
    // 1. 코미디 / 사이다
    ChatbotMovieData(
      id: 567646,
      title: '극한직업',
      overview: '낮에는 치킨장사 밤에는 잠복근무를 펼치는 마약반 형사들의 눈물겨운 위장창업 코미디.',
      posterPath: '/bF1kMeqtI2GZgD0o4d6p1Zl2L1s.jpg',
      voteAverage: 8.3,
      releaseDate: '2019-01-23',
      reason: '배꼽 빠지는 대사와 찰떡같은 케미로 복잡한 머리를 시원하게 비워줍니다.',
      tags: ['#웃음보장', '#스트레스해소', '#치킨생각'],
      categories: ['코미디', '스트레스', '혼맥', '기분_코미디'],
    ),
    ChatbotMovieData(
      id: 595743,
      title: '엑시트',
      overview: '유독가스로 뒤덮인 도심을 탈출해야 하는 청년백수와 동아리 후배의 기상천외한 탈출 액션.',
      posterPath: '/h3Y43N9U5nQe434e7g364L7mN1p.jpg',
      voteAverage: 8.0,
      releaseDate: '2019-07-31',
      reason: '군더더기 없는 전개와 통쾌한 클라이밍 액션으로 가슴이 뻥 뚫립니다.',
      tags: ['#슬랩스틱사이다', '#청춘응원', '#재난탈출'],
      categories: ['코미디', '액션', '스트레스', '기분_코미디'],
    ),

    // 2. 힐링 / 감동
    ChatbotMovieData(
      id: 122906,
      title: '어바웃 타임',
      overview: '시간을 되돌릴 수 있는 능력을 알게 된 주인공이 인생의 진정한 행복과 사랑을 깨닫는 이야기.',
      posterPath: '/iT91Uj5r3T4V7a4s9L8X6Z5M4K.jpg',
      voteAverage: 8.4,
      releaseDate: '2013-12-05',
      reason: '하루의 소중함과 따뜻한 인생의 의미를 일깨워주는 위로작입니다.',
      tags: ['#인생명작', '#따뜻한위로', '#마음정리'],
      categories: ['힐링', '로맨스', '데이트', '기분_힐링'],
    ),
    ChatbotMovieData(
      id: 129,
      title: '센과 치히로의 행방불명',
      overview: '신들의 세계에 발을 들인 소녀 치히로가 성장하며 진정한 자신을 찾아가는 환상적 모험.',
      posterPath: '/39wmItIWsg5sZMyRUHLkWBcuVCM.jpg',
      voteAverage: 8.5,
      releaseDate: '2001-07-20',
      reason: '아름다운 작화와 음악 속에서 지친 영혼이 깨끗해지는 힐링의 정수입니다.',
      tags: ['#지브리감성', '#어른을위한동화', '#마음회복'],
      categories: ['힐링', '애니메이션', '기분_힐링'],
    ),

    // 3. 액션 / 몰입
    ChatbotMovieData(
      id: 383498,
      title: '데드풀',
      overview: '정의감은 전혀 없지만 거침없는 입담과 통쾌한 검술로 악당들을 응징하는 안티히어로 액션.',
      posterPath: '/inVq3wo8fHaHpVppQlTM12f7R2c.jpg',
      voteAverage: 7.8,
      releaseDate: '2016-02-17',
      reason: '화끈한 액션과 직설적인 유머로 머릿속 잡생각을 완전히 날려버립니다.',
      tags: ['#화끈한타격감', '#청불액션', '#킬링타임'],
      categories: ['액션', '스트레스', '혼맥', '기분_액션'],
    ),
    ChatbotMovieData(
      id: 76341,
      title: '매드맥스: 분노의 도로',
      overview: '물과 기름을 차지한 독재자에 맞서 생존을 위해 펼치는 분노의 도로 질주 액션 블록버스터.',
      posterPath: '/8tZYtuWezp8JbcsvHYO0O46tFbo.jpg',
      voteAverage: 8.2,
      releaseDate: '2015-05-14',
      reason: '처음부터 끝까지 멈추지 않는 거친 엔진 소리와 몰입감이 압도적입니다.',
      tags: ['#질주본능', '#아드레날린폭발', '#시각적충격'],
      categories: ['액션', '주말', '기분_액션'],
    ),

    // 4. 감동 / 눈물
    ChatbotMovieData(
      id: 278,
      title: '쇼생크 탈출',
      overview: '누명을 쓰고 악명 높은 교도소에 갇힌 앤디가 오랜 세월 동안 품어온 희망과 구원의 대서사시.',
      posterPath: '/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg',
      voteAverage: 8.7,
      releaseDate: '1994-09-23',
      reason: '벅차오르는 감동과 자유의 환희로 가슴 깊은 곳을 울립니다.',
      tags: ['#역대평점1위', '#희망의빛', '#인생작'],
      categories: ['감동', '인생작', '기분_드라마', '명작'],
    ),
    ChatbotMovieData(
      id: 11423,
      title: '살인의 추억',
      overview: '1986년 연쇄살인사건을 추적하는 두 형사의 집념과 시대의 아픔을 담아낸 수작.',
      posterPath: '/je02fB6lD3x3m1hR6M7H9E7z9.jpg',
      voteAverage: 8.3,
      releaseDate: '2003-04-25',
      reason: '끝까지 시선을 뗄 수 없는 긴장감과 시대를 관통하는 여운이 깊습니다.',
      tags: ['#봉준호감독', '#한국스릴러정점', '#묵직한여운'],
      categories: ['스릴러', '비오는날', '기분_드라마'],
    ),

    // 5. 반전 / 미스터리
    ChatbotMovieData(
      id: 496243,
      title: '기생충',
      overview: '전원백수인 기택네 장남이 박사장네 과외선생으로 들어가면서 시작되는 걷잡을 수 없는 가족 희비극.',
      posterPath: '/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg',
      voteAverage: 8.5,
      releaseDate: '2019-05-30',
      reason: '예측할 수 없는 반전과 치밀한 서스펜스가 숨을 멎게 만듭니다.',
      tags: ['#칸황금종려상', '#충격반전', '#디테일천재'],
      categories: ['반전', '스릴러', '주말', '명작'],
    ),
    ChatbotMovieData(
      id: 670,
      title: '올드보이',
      overview: '영문도 모른 채 15년 동안 갇혀 있던 오대수가 풀려나 자신을 가둔 자의 진실을 파헤치는 복수극.',
      posterPath: '/5M1g3e1eLqB5Q5Pq5M1g3e1eLqB.jpg',
      voteAverage: 8.3,
      releaseDate: '2003-11-21',
      reason: '한국 영화사상 가장 충격적인 결말과 장도리 액션의 미학이 돋보입니다.',
      tags: ['#박찬욱감독', '#파격적서사', '#레전드반전'],
      categories: ['반전', '스릴러', '심야'],
    ),

    // 6. SF / 스케일
    ChatbotMovieData(
      id: 157336,
      title: '인터스텔라',
      overview: '세계 각국의 붕괴 속에서 인류를 구하기 위해 시공간을 넘어 우주로 떠나는 탐험가들의 여정.',
      posterPath: '/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
      voteAverage: 8.6,
      releaseDate: '2014-11-06',
      reason: '압도적인 우주 영상미와 가슴 먹먹한 부성애가 우주 끝까지 전해집니다.',
      tags: ['#크리스토퍼놀란', '#차원초월', '#감동SF'],
      categories: ['SF', '주말', '명작'],
    ),
    ChatbotMovieData(
      id: 27205,
      title: '인셉션',
      overview: '타인의 꿈에 들어가 생각을 훔치거나 심는 특수 작전을 펼치는 도둑들의 다층 구조 SF 액션.',
      posterPath: '/o2zA5B0xRz7o6L5lQ4K3J2H1G0F.jpg',
      voteAverage: 8.4,
      releaseDate: '2010-07-21',
      reason: '꿈과 현실의 경계를 넘나드는 놀라운 상상력과 두뇌 게임이 일품입니다.',
      tags: ['#꿈속의꿈', '#토템결말', '#지적스릴'],
      categories: ['SF', '반전', '주말'],
    ),

    // 7. 예술 / 로맨스
    ChatbotMovieData(
      id: 313369,
      title: '라라랜드',
      overview: '꿈을 꾸는 사람들을 위한 도시 LA에서 만난 재즈 피아니스트와 배우 지망생의 열정과 사랑.',
      posterPath: '/uDO8zWDdoWjYqaWkGzLYz9GRvsv.jpg',
      voteAverage: 8.1,
      releaseDate: '2016-12-07',
      reason: '환상적인 색감과 재즈 음악, 그리고 잊히지 않는 아련한 엔딩을 선사합니다.',
      tags: ['#음악영화', '#색채미학', '#여운짙은엔딩'],
      categories: ['예술', '로맨스', '데이트', '심야'],
    ),
    ChatbotMovieData(
      id: 705996,
      title: '헤어질 결심',
      overview: '변사 사건을 수사하게 된 형사가 사망자의 아내를 만나 의심과 관심을 동시에 품게 되는 멜로 스릴러.',
      posterPath: '/mQJd9fF5f3h0a1g4d2e8b6c.jpg',
      voteAverage: 8.0,
      releaseDate: '2022-06-29',
      reason: '밀도 높은 감정선과 미장센으로 안개처럼 스며드는 사랑의 본질을 보여줍니다.',
      tags: ['#박찬욱탕웨이', '#서스펜스멜로', '#미장센끝판왕'],
      categories: ['예술', '스릴러', '비오는날', '심야'],
    ),
  ];
}
