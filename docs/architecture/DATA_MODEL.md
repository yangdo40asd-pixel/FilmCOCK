# 데이터 모델과 보존 정책

갱신일: 2026-11-17 · 상태: 현재 코드 기준 / 구조 이관 중

## 저장 매체

SharedPreferences에 문자열·불리언·문자열 목록을 보관한다. JSON 목록은 각 항목을 문자열로 인코딩한다. Firebase Authentication은 로그인 세션을 담당하며 로컬 활동 저장과 별개다.

| 데이터 | 키·형식 | 현재 소유 범위·동작 |
| --- | --- | --- |
| 비회원 세션 | guest_mode, guest_session_id | 기기 키, 새 비회원 세션 ID 발급 |
| MBTI | user_mbti::user_UID 또는 ::guest_ID | 현재 사용자별 문자열 |
| 장르 | user_genres::소유자 | 장르 문자열 목록 |
| 온보딩 | mbti_decided::소유자, genres_decided::소유자 | 선택·건너뛰기 결정 여부, 두 값으로 완료 판정 |
| 이전 온보딩 | onboarding_complete, user_mbti, user_genres | 레거시 키, 자동 소유자 승계하지 않음 |
| 좋아요 영화 | liked_movies_data, liked_movie_ID | 기기 공용 JSON 문자열 목록 + 개별 플래그 |
| 관람 영화 | watched_movies_data, watched_movie_ID | 기기 공용 목록 + 개별 플래그 |
| 좋아요 인물 | liked_people, liked_person_ID | 기기 공용 목록 + 개별 플래그 |
| 댓글 | user_comments | movieId, movieTitle, posterPath, content, date 등을 가진 목록 |
| 캘린더 | calendar_movies_data | 날짜 키 → 영화 항목 배열인 JSON 객체 |
| 프로필 | user_nickname, user_bio, user_profile_image | 기기 공용 문자열, 이미지 경로는 로컬 파일 |
| 최근 검색 | recent_searches | 최대 10개 검색 문자열 |
| 홈 캐시 | home_last_good_v1 | 마지막 정상 섹션 데이터와 saved_at |
| 개봉 안내 | last_upcoming_alert | 사용자·날짜·영화 식별값 |
| 기기 설정 | is_dark_mode, setting_all_push, setting_upcoming_movie_alarm | 로그아웃 시 보존 |

Firebase 초기화 전에는 취향 저장소의 소유자가 anonymous가 될 수 있다. 테스트가 예전 user_mbti만 넣는 경우 현재 저장소의 읽기 키와 일치하지 않으므로 fixture 정리가 필요하다.

## 홈 캐시

HomePrefetchService는 메모리 정상 캐시를 약 30분 유지한다. HomeCacheStorage는 SharedPreferences에 마지막 정상 홈 데이터를 저장하고 앱 시작 때 복원한다. 디스크 복구값이 있다는 사실과 네트워크 정상 캐시 TTL은 별도 정책이다. saved_at이 저장된다고 디스크 복구값에 자동 만료가 적용된 것으로 설명하지 않는다.

## 로그아웃·탈퇴

LocalUserDataService는 AppStorageKeys.isUserScoped에 해당하는 모든 키와 프로필 이미지 파일 정리를 시도한다. 따라서 현재 구현은 다른 사용자 접미사 키까지 지울 수 있다. 이 동작을 계정별 영구 보관으로 설명하지 않는다. 앱 콜드 스타트에서 인증 사용자가 없으면 비회원 세션을 종료한다.

## 리팩토링 보존 규약

- 폴더 이동만으로 저장 키·형식·정리 범위를 바꾸지 않는다.
- 활동 목록과 개별 플래그는 현재 함께 쓰인다. 단일 쓰기 계약으로 정리하되 호환 데이터를 보존한다.
- SharedPreferences 다중 쓰기는 원자적이지 않다. 실패 결과와 중간 상태를 고려한다.
- 프로필 파일의 상대·절대 경로 변경은 실제 파일 이관과 함께 처리한다.
- 사용자 소유자 분리를 확대할 때 기존 기기 공용 기록을 임의의 계정에 귀속시키지 않는다.
- 스키마 변경은 버전·백업·재시도·역방향 호환 규칙을 먼저 정하고 별도 변경으로 진행한다.

## 이번 리팩토링의 저장 변경

저장 키와 JSON 형식을 유지했으므로 스키마 버전 전환과 데이터 이관은 도입하지 않았다. SafeJsonStorage·UserSettingsRepository의 저장 구현과 사용자 식별자를 주입할 수 있게 했다. ActivityRepository는 활동 변경을 직렬화하고 목록·플래그·관람 캘린더를 함께 조정한다. 여러 쓰기 중 실패하면 이전 값 복원을 시도하며 성공한 작업 뒤에만 변경 신호를 발행한다. 저장 장치가 계속 실패할 때까지 원자성을 보장하는 구조는 아니다.

