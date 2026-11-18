# 요구사항과 구현 추적

갱신일: 2026-11-17 · 상태: 구조 이관 중 / 실행 검증 대기

코드 위치는 현재 경로 기준이다. 기능별 이동이 끝나면 새 경로로 갱신한다. 아래 근거는 소스이며 현재 변경분의 실테스트 결과가 아니다.

| 요구사항 | 현재 구현 진입점 | 사용자 확인 묶음 |
| --- | --- | --- |
| FR-01 인증 | lib/features/auth/presentation/screens/login_screen.dart, profile/settings_screen.dart | 1·2 |
| FR-02 온보딩 | lib/app/routing/startup_destination.dart, lib/features/preferences/data/user_settings_repository.dart | 1·2 |
| FR-03 홈 준비·복구 | lib/app/bootstrap/startup_flow.dart, lib/features/home/data/home_prefetch_service.dart | 1·2 |
| FR-04 MBTI 제목·이전 목록 | lib/features/home/presentation/screens/home_screen.dart | 1 |
| FR-05 검색 | lib/features/search/application/search_screen_controller.dart, search 화면 | 1·2 |
| FR-06 상세·시청 | lib/presentation/screens/detail, lib/features/movie_detail/presentation/widgets/watch_options_sheet.dart | 1·2 |
| FR-07 활동 반영 | lib/features/activity/data/activity_repository.dart, profile/my_page_screen.dart | 1·2 |
| FR-08 달력·등급 | calendar/calendar_screen.dart, lib/features/profile/presentation/widgets/my_page_tier_section.dart | 1 |
| FR-09 규칙·LLM 대체 | lib/features/chat/application/chatbot_service.dart, lib/data/llm | 1·2 |
| FR-10 후보 확인·대화 | chatbot_service.dart, chat/chat_screen.dart | 1·2 |
| FR-11 공통 취향 | lib/features/recommendations/application/personalized_recommendation_service.dart | 1 |
| FR-12 테마·재시도 | lib/core/theme, lib/presentation/widgets | 1·2 |

비기능 요구 NFR-01·02는 키 제외·저장 키 보존 규약, NFR-03은 시작 처리의 수명, NFR-04·05는 P2·P4의 의존성 주입·검증 격리 작업, NFR-06은 검증 기록에 연결한다.

두 확인 묶음의 체크 상태는 [진행표](../planning/PORTFOLIO_REFACTORING_PLAN.md)의 사용자 실테스트 항목에서 관리한다.
