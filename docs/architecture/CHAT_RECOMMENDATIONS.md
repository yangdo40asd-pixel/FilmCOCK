# 챗봇과 취향 추천 구조

갱신일: 2026-11-17 · 상태: 현재 코드 기준

## 대화 흐름

- ChatSessionController: 메시지·처리 상태·요청 번호를 소유한다. 초기화하면 이전 서비스와 새 서비스를 분리한다.
- ChatbotService: 의도와 추천 흐름을 조정하고 최근 추천 이력을 관리한다.
- CuratedRule: 12개 정적 의도의 문구와 큐레이션 분류를 보관한다.
- LlmPlanInterpreter: LLM 호출·시간 제한·ChatPlan 형식 검증을 담당한다.
- MovieCandidateVerifier: 제안 제목을 검색 결과와 비교하고 제외·중복 작품을 제거한다.
- FirebaseLlmClient: 실제 Firebase AI Logic 구현이다. 단위 검사에는 가짜 또는 비활성 구현을 사용한다.

질문 칩은 규칙 처리다. 자유 입력은 LLM 사용 가능 시 먼저 시도하며 실패하거나 유효 후보가 없으면 규칙·큐레이션으로 이어진다. LLM 원문 응답과 예외 내용을 디버그 로그에 그대로 출력하지 않는다.

## 공통 취향

PreferenceRepository가 현재 소유자의 MBTI·장르를 PreferenceSnapshot으로 제공한다. 홈·취향·챗봇은 PersonalizedRecommendationService의 같은 조건 계산을 사용한다. 선택 장르를 먼저 넣고 MBTI 장르를 추가한 집합에서 최대 3개를 사용한다. 이 우선순위는 이번 구조 변경에서 유지했다.

장르별 결과는 영화 ID로 중복을 제거하고 좋아요·관람 기록을 제외한다. API 실패 시 전달받은 fallback 목록을 사용한다. MBTI 장르 규칙은 학습 추천이나 심리학적 적합성 보장이 아니다.

홈 제목은 장르를 붙이지 않고 오늘의 추천 영화 (MBTI) 형식을 유지한다. 대화에 표현되는 추천 근거와 서비스 실패 대체 여부는 별도 표시 정책이다.
