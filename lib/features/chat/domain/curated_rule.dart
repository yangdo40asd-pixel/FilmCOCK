import 'chat_intent.dart';

class CuratedRule {
  final List<String> categories;
  final String message;
  const CuratedRule(this.categories, this.message);

  static CuratedRule? forIntent(ChatIntent intent) => _rules[intent];

  static const _rules = <ChatIntent, CuratedRule>{
    ChatIntent.healing: CuratedRule([
      '힐링',
    ], '몸과 마음이 지쳤을 때는 자극 없는 따뜻한 이야기가 최고의 처방입니다. 마음에 잔잔한 여운을 줄 힐링 작품들을 추천합니다.'),
    ChatIntent.stressRelief: CuratedRule([
      '스트레스',
      '코미디',
    ], '답답했던 속을 시원하게 뚫어줄 유쾌하고 통쾌한 사이다 영화들입니다. 복잡한 생각 없이 마음껏 웃어보세요.'),
    ChatIntent.emotional: CuratedRule([
      '감동',
      '기분_드라마',
    ], '마음껏 감정을 비워내고 깊은 여운을 느낄 수 있는 감동적인 작품들입니다.'),
    ChatIntent.beerNight: CuratedRule([
      '혼맥',
      '액션',
    ], '시원한 캔맥주 한 캔과 함께 가볍게 감상하기 좋은 작품들입니다. 편안한 혼자만의 밤을 만끽해보세요.'),
    ChatIntent.weekend: CuratedRule([
      '주말',
      '스릴러',
    ], '주말 동안 시간 가는 줄 모르고 빠져들 수 있는 높은 완성도의 명작들입니다. 빈틈없는 몰입감을 선사합니다.'),
    ChatIntent.thriller: CuratedRule([
      '반전',
      '스릴러',
    ], '마지막 순간까지 방심할 수 없는 치밀한 두뇌 싸움과 충격적인 결말의 스릴러 명작입니다. 결말의 전율을 직접 느껴보세요.'),
    ChatIntent.romance: CuratedRule([
      '로맨스',
      '데이트',
    ], '보는 내내 마음에 기분 좋은 설렘과 따뜻한 온기를 불어넣어 줄 검증된 로맨스 작품들입니다.'),
    ChatIntent.rainyDay: CuratedRule([
      '비오는날',
      '스릴러',
    ], '창밖 빗소리와 함께 방 안에서 불을 끄고 집중하기 좋은 묵직한 분위기의 미스터리 수작입니다.'),
    ChatIntent.midnight: CuratedRule([
      '심야',
    ], '조용한 밤의 분위기와 잘 어울리는 몰입도 높은 작품들입니다.'),
    ChatIntent.art: CuratedRule(['예술'], '영상과 음악의 조화를 오래 기억할 수 있는 예술적인 작품들입니다.'),
    ChatIntent.scienceFiction: CuratedRule([
      'SF',
    ], '경이로운 우주 영상미와 독창적인 상상력이 돋보이는 SF 대작들입니다. 가슴 벅찬 감동을 경험해보세요.'),
    ChatIntent.comedy: CuratedRule([
      '코미디',
    ], '쉴 새 없이 터지는 대사와 유쾌한 상황극으로 스트레스를 단숨에 날려버릴 한국 코미디 명작입니다.'),
  };
}
