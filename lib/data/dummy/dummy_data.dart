import 'package:filmcock_app/data/models/movie_model.dart';

final List<Person> dummyActors = [
  Person(
    id: 71519,
    name: '강동원',
    knownForDepartment: 'Acting',
    profilePath: '/8c5iAIyV1u5t5T4vD5E5F6G7H8.jpg',
  ),
  Person(
    id: 20376,
    name: '이병헌',
    knownForDepartment: 'Acting',
    profilePath: '/A1v3vXmHl293z4yI9W4C6I4S3a.jpg',
  ),
  Person(
    id: 20377,
    name: '장동건',
    knownForDepartment: 'Acting',
    profilePath: '/31l2i3m4n5o6p7q8r9s0t1u2v3.jpg',
  ),
  Person(
    id: 97416,
    name: '마동석',
    knownForDepartment: 'Acting',
    profilePath: '/93oA8i25p9hQdnc2j4s2yO2Zk5c.jpg',
  ),
];

final List<Person> dummyDirectors = [
  Person(
    id: 21684,
    name: '봉준호',
    knownForDepartment: 'Directing',
    profilePath: '/wB8dYy3a4c5a6d7e8f9g0h1i2j.jpg',
  ),
  Person(
    id: 28933,
    name: '박찬욱',
    knownForDepartment: 'Directing',
    profilePath: '/a1b2c3d4e5f6g7h8i9j0k1l2m3n.jpg',
  ),
  Person(
    id: 525,
    name: '크리스토퍼 놀란',
    knownForDepartment: 'Directing',
    profilePath: '/5Ulg8p23a4b5c6d7e8f9g0h1i2j.jpg',
  ),
];

final List<ReviewChannel> dummyChannels = [
  ReviewChannel(name: '천재이승국', logoAsset: 'assets/images/channel_1.jpg'),
  ReviewChannel(name: '거의없다', logoAsset: 'assets/images/channel_2.jpg'),
  ReviewChannel(name: '김시선', logoAsset: 'assets/images/channel_3.jpg'),
  ReviewChannel(name: '라이너', logoAsset: 'assets/images/channel_4.jpg'),
  ReviewChannel(name: '삐맨', logoAsset: 'assets/images/channel_5.jpg'),
];

// 배우별 대표작 목록 (영화 제목 대신 고유 ID 사용)
final Map<int, List<int>> manualFilmography = {
  // 마동석 (97416)
  97416: [
    442249,
    842544, // 범죄도시 2
    493922,
    438631,
    524434,
  ], // 범죄도시1, 범죄도시2, 신과함께1, 부산행, 이터널스
  // 장동건 (20377)
  20377: [
    6239,
    10733,
    11549,
    460885,
    114472,
    460790,
  ], // 태극기 휘날리며, 친구, 무극, 7년의 밤, 위험한 관계, 브이아이피
  // 이병헌 (20376)
  20376: [
    341006,
    49017,
    403789,
    238636,
    40849,
    644106,
  ], // 내부자들, 악마를 보았다, 마스터, 지아이조2, 밀정, 남산의 부장들
  // 강동원 (71519) - dummyActors에 있지만 목록에 없어 비워둠
  71519: [],
  // 하정우 (72348)
  72348: [
    334533,
    493922,
    396535,
    97313,
    104058,
    13833,
  ], // 암살, 신과함께1, 터널, 범죄와의 전쟁, 러브픽션, 추격자
  // 황정민 (62396)
  62396: [
    381283,
    303973,
    97313,
    158403,
    341013,
    250325,
  ], // 곡성, 국제시장, 범죄와의 전쟁, 신세계, 베테랑, 남자가 사랑할 때
  // 송강호 (22970)
  22970: [
    496243,
    221495,
    1155,
    16995,
    241249,
    434821,
  ], // 기생충, 관상, 괴물, 밀양, 변호인, 택시운전사
  // 원빈 (71580)
  71580: [48386, 6239, 29144, 22673], // 아저씨, 태극기 휘날리며, 우리형, 마더
};
