class MbtiInfo {
  final String id;
  final String title;
  final String description;
  final String feature;
  final String recommendedGenres;
  final List<String> genreIds;
  final List<String> famousPeople;
  final String svgAsset;

  const MbtiInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.feature,
    required this.recommendedGenres,
    required this.genreIds,
    required this.famousPeople,
    required this.svgAsset,
  });
}

const List<MbtiInfo> mbtiInfoList = [
  MbtiInfo(id: 'ISTJ', title: '청렴결백한 논리주의자', description: '성실하고 책임감이 강한 완벽주의자', feature: '신뢰할 수 있고, 사실에 근거하여 행동하며, 의무와 규칙을 중시해요!', recommendedGenres: '탄탄한 스토리와 논리적 전개가 있는 범죄, 역사, 드라마 영화를 추천해요.', genreIds: ['crime', 'history', 'drama'], famousPeople: ['조지 워싱턴', '워렌 버핏', '율 브리너'], svgAsset: 'assets/images/mbti/istj.svg'),
  MbtiInfo(id: 'ISFJ', title: '용감한 수호자', description: '따뜻하고 헌신적인 보호자', feature: '공감 능력이 뛰어나고 주변 사람들을 세심하게 챙기는 것을 좋아해요!', recommendedGenres: '감동적인 가족 이야기와 따뜻한 드라마, 로맨스 영화를 추천해요.', genreIds: ['family', 'drama', 'romance'], famousPeople: ['아이리스 머독', '빅토리아 여왕', '나이팅게일'], svgAsset: 'assets/images/mbti/isfj.svg'),
  MbtiInfo(id: 'ESTJ', title: '엄격한 관리자', description: '체계적이고 추진력이 강한 지도자', feature: '명확한 규칙과 구조를 선호하며, 결과를 위해 적극적으로 행동해요!', recommendedGenres: '긴장감 넘치는 전쟁, 범죄, 액션 영화가 잘 어울려요.', genreIds: ['war', 'crime', 'action'], famousPeople: ['프랭크 시나트라', '존 록펠러', '드와이트 아이젠하워'], svgAsset: 'assets/images/mbti/estj.svg'),
  MbtiInfo(id: 'ESFJ', title: '사교적인 외교관', description: '친절하고 사교적인 조화의 아이콘', feature: '사람들 사이의 화합을 중시하며 주변에 긍정적 에너지를 퍼뜨려요!', recommendedGenres: '따뜻하고 유쾌한 코미디, 로맨스, 가족 영화를 추천해요.', genreIds: ['comedy', 'romance', 'family'], famousPeople: ['테일러 스위프트', '엘튼 존', '스티브 어윈'], svgAsset: 'assets/images/mbti/esfj.svg'),
  MbtiInfo(id: 'INFJ', title: '선의의 옹호자', description: '통찰력 있는 이상주의 비전가', feature: '깊은 통찰력과 강한 직관으로 세상을 더 나은 곳으로 만들고 싶어해요!', recommendedGenres: '깊은 메시지를 담은 SF, 판타지, 다큐멘터리 영화를 추천해요.', genreIds: ['sf', 'fantasy', 'documentary'], famousPeople: ['마틴 루터 킹', '넬슨 만델라', '아우구스티누스'], svgAsset: 'assets/images/mbti/infj.svg'),
  MbtiInfo(id: 'INFP', title: '열정적인 중재자', description: '창의적이고 감수성 풍부한 몽상가', feature: '자신만의 가치관과 이상을 추구하며 예술적 감성이 매우 뛰어나요!', recommendedGenres: '감성적이고 아름다운 애니메이션, 판타지, 드라마 영화를 추천해요.', genreIds: ['animation', 'fantasy', 'drama'], famousPeople: ['J.R.R. 톨킨', '존 레논', '오드리 헵번'], svgAsset: 'assets/images/mbti/infp.svg'),
  MbtiInfo(id: 'ENFJ', title: '정의로운 사회운동가', description: '카리스마 넘치는 영감을 주는 지도자', feature: '사람들에게 영감을 주고 잠재력을 이끌어내는 타고난 지도자예요!', recommendedGenres: '감동적인 휴먼 드라마, 역사, 전기 영화를 추천해요.', genreIds: ['drama', 'history', 'documentary'], famousPeople: ['버락 오바마', '오프라 윈프리', '마야 안젤루'], svgAsset: 'assets/images/mbti/enfj.svg'),
  MbtiInfo(id: 'ENFP', title: '재기발랄한 활동가', description: '자유로운 영혼의 창의적 탐험가', feature: '새로운 가능성에 흥분하며, 창의적이고 열정적으로 삶을 즐겨요!', recommendedGenres: '신나고 재기발랄한 어드벤처, 코미디, 음악 영화를 추천해요.', genreIds: ['adventure', 'comedy', 'music'], famousPeople: ['로빈 윌리엄스', '엘렌 드제너러스', '롤드 달'], svgAsset: 'assets/images/mbti/enfp.svg'),
  MbtiInfo(id: 'INTJ', title: '용의주도한 전략가', description: '독립적이고 단호한 마스터마인드', feature: '장기적인 계획을 세우고 독창적인 방식으로 목표를 달성해요!', recommendedGenres: '복잡한 구성과 반전이 있는 SF, 스릴러, 미스터리 영화를 추천해요.', genreIds: ['sf', 'thriller', 'mystery'], famousPeople: ['일론 머스크', '니콜라 테슬라', '스티븐 호킹'], svgAsset: 'assets/images/mbti/intj.svg'),
  MbtiInfo(id: 'INTP', title: '논리적인 사색가', description: '지식을 탐구하는 창의적 발명가', feature: '논리와 이론을 통해 세상을 이해하려 하며 독창적인 아이디어가 넘쳐요!', recommendedGenres: '지적 호기심을 자극하는 SF, 다큐멘터리, 미스터리 영화를 추천해요.', genreIds: ['sf', 'documentary', 'mystery'], famousPeople: ['알버트 아인슈타인', '빌 게이츠', '찰스 다윈'], svgAsset: 'assets/images/mbti/intp.svg'),
  MbtiInfo(id: 'ENTJ', title: '대담한 통솔자', description: '강인하고 결단력 있는 혁신 리더', feature: '비효율적인 것을 참지 못하며, 강한 의지로 목표를 이루어내요!', recommendedGenres: '굵직한 서사와 전략적 대결이 있는 전쟁, 범죄, 액션 영화를 추천해요.', genreIds: ['war', 'crime', 'action'], famousPeople: ['스티브 잡스', '나폴레옹', '마거릿 대처'], svgAsset: 'assets/images/mbti/entj.svg'),
  MbtiInfo(id: 'ENTP', title: '뜨거운 논쟁을 즐기는 변론가', description: '독창적이고 도발적인 아이디어 뱅크', feature: '지적 토론을 즐기며 새로운 방식으로 문제를 해결하는 것에 탁월해요!', recommendedGenres: '예상을 뒤엎는 코미디, 스릴러, SF 영화를 추천해요.', genreIds: ['comedy', 'thriller', 'sf'], famousPeople: ['마크 트웨인', '볼테르', '에릭 안드레'], svgAsset: 'assets/images/mbti/entp.svg'),
  MbtiInfo(id: 'ISTP', title: '만능 재주꾼', description: '대담하고 현실적인 실험 정신의 소유자', feature: '손으로 무언가를 만들거나 분석하는 것을 좋아하며 침착하고 냉정해요!', recommendedGenres: '스피디하고 긴장감 넘치는 액션, 스릴러, 범죄 영화를 추천해요.', genreIds: ['action', 'thriller', 'crime'], famousPeople: ['클린트 이스트우드', '마이클 조던', '브루스 리'], svgAsset: 'assets/images/mbti/istp.svg'),
  MbtiInfo(id: 'ISFP', title: '호기심 많은 예술가', description: '자유로운 영혼의 감성적 모험가', feature: '아름다움에 민감하며, 자유롭고 즉흥적인 삶의 방식을 추구해요!', recommendedGenres: '감각적이고 아름다운 로맨스, 음악, 애니메이션 영화를 추천해요.', genreIds: ['romance', 'music', 'animation'], famousPeople: ['마이클 잭슨', '프리다 칼로', '피카소'], svgAsset: 'assets/images/mbti/isfp.svg'),
  MbtiInfo(id: 'ESTP', title: '모험을 즐기는 사업가', description: '뚝뚝하고 에너지 넘치는 활동가', feature: '에너지가 넘치고 모험을 즐기며, 현실적인 문제 해결 능력이 뛰어나요!', recommendedGenres: '화려한 볼거리와 짜릿한 쾌감을 주는 액션, 스포츠, 범죄 영화를 추천해요.', genreIds: ['action', 'sports', 'crime'], famousPeople: ['도널드 트럼프', '어니스트 헤밍웨이', '잭 니콜슨'], svgAsset: 'assets/images/mbti/estp.svg'),
  MbtiInfo(id: 'ESFP', title: '자유로운 영혼의 연예인', description: '즉흥적이고 활기차며 삶을 사랑하는 엔터테이너', feature: '어디서나 분위기를 밝게 만들고, 사람들과 함께 즐기는 걸 좋아해요!', recommendedGenres: '신나고 유쾌한 코미디, 음악, 어드벤처 영화를 추천해요.', genreIds: ['comedy', 'music', 'adventure'], famousPeople: ['마릴린 먼로', '엘비스 프레슬리', '윌 스미스'], svgAsset: 'assets/images/mbti/esfp.svg'),
];

MbtiInfo? getMbtiInfoById(String id) {
  try {
    return mbtiInfoList.firstWhere((e) => e.id == id);
  } catch (_) {
    return null;
  }
}
