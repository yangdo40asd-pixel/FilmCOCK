# 기술 사례와 설명 근거

갱신일: 2026-11-17 · 상태: 소스 근거 / 이번 변경분 실행 미검증

## 오래된 화면 상태

활동 저장 후 IndexedStack에 남아 있는 마이페이지가 예전 목록을 표시하는 문제가 과거 작업에서 다뤄졌다. 현재는 저장 성공 후 변경 신호와 요청 번호 기반 재조회가 있다. 이번에는 활동 목록·플래그·캘린더 쓰기를 저장소 작업으로 모으고 저장 실패 복원과 직렬 처리를 추가했다.

설명할 코드: features/activity/data/activity_repository.dart, features/profile/presentation/screens/my_page_screen.dart. 검사 소스: test/unit/activity/activity_repository_test.dart.

## 검색 응답 순서

늦게 도착한 이전 조회가 최신 검색 결과를 덮는 위험을 요청 번호로 제어한다. 자동완성과 결과 페이지 상태를 컨트롤러로 분리해 화면과 요청 수명을 구분했다.

설명할 코드: features/search/application. 검사 소스: test/unit/search/search_results_controller_test.dart.

## AI 후보 확인과 규칙 대체

질문 칩과 자유 입력을 구분하고, LLM 결과를 구조화한 뒤 영화 제목을 외부 조회 결과와 비교한다. 형식 오류·외부 실패는 규칙으로 대체한다. 대화 초기화 때 이전 요청은 새 세션과 분리한다.

설명할 코드: features/chat/application의 interpreter, verifier, session_controller. 검사 소스: test/unit/chat.

## 구조 변경의 선택

상태관리·DB 전체 교체 대신 공용 계약, 기능별 폴더, 순수 정책, UI 조각을 단계적으로 분리했다. API 공급자·에셋 경로·저장 스키마를 유지해 변경 범위를 제한했다.

측정하지 않은 속도 향상률·정확도·사용자 만족도를 성과로 적지 않는다. 실제 결과는 quality/VALIDATION_LOG.md에 추가한다.
