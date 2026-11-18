# 리팩토링 작업 기록

갱신일: 2026-11-17 · 상태: 순차 코드·문서 정리 완료 / 사용자 실행 검증 대기

## 기준과 복구 지점

- 시작 커밋: f2c3e98
- 원래 브랜치: fix/theme-poster-chatbot
- 작업 브랜치: codex/portfolio-refactor
- 시작 시 미커밋 파일은 앞서 작성한 docs/planning 계획서뿐이었다.
- 2026-11-18 README 개선과 GitHub 업로드를 진행한다. 기존 기준 브랜치와 커밋은 보존하며 게시 결과는 Git 이력에서 확인한다.
- 런타임 에셋·실제 키·로컬 저장 키·JSON 형식은 변경하지 않았다.

## 중첩 저장소 보존

FilmCOCK!는 main 브랜치, 커밋 64a694b, 별도 원격 FilmCOCK-.git을 가진다. 추적 파일은 .gitattributes 하나이며 미커밋 파일이 없었다. 상위 저장소에는 gitlink로 등록돼 있으나 .gitmodules가 없다.

독립 이력 전체를 아래 로컬 위치에 Git bundle로 보관하고 Git의 bundle 무결성 확인을 마쳤다.

```text
C:/Users/admin_25/Downloads/Filmcock-refactor-backups/2026-11-17/nested-filmcock-history.bundle
```

원본 내부 .git과 상위 gitlink는 유지했다. 제거·정식 submodule 전환·별도 저장소 유지 중 최종 선택은 후속 저장소 정리에서 다룬다. 이 폴더는 앱 런타임 코드가 아니다. 백업은 GitHub 업로드 대상이 아니다.

## 자료 이동

기존 문서 5개와 디자인 자료 4개 묶음을 역할별로 이동했다.

| 이전 | 이후 |
| --- | --- |
| docs/API_KEYS_SETUP.md | docs/development/API_KEYS_SETUP.md |
| MAINTENANCE_CHECKLIST.md | docs/archive/MAINTENANCE_CHECKLIST_2026-09.md |
| docs의 과거 TXT 3개 | docs/archive/ 안의 동일 파일명 |
| catpure/ | docs/references/design/legacy-captures/ |
| imgicon/ | docs/references/design/source-images/ |
| mbti/ | docs/references/design/mbti-originals/ |
| 1.png | docs/references/design/brand-original.png |

대표 브랜드 이미지와 MBTI SVG 16개는 각각 실행 assets 파일과 SHA-256이 일치했다. 원본을 삭제하지 않고 참고 자료로 분리했다. 현재 버전 시연 화면으로 선별하지 않았다.

## 코드 변경

- main.dart: Flutter 바인딩·API 설정·테마 준비와 runApp만 유지.
- app/app.dart: MyApp과 초기 오류·재시도 UI를 기존 main에서 분리.
- app/bootstrap/app_bootstrap.dart: Firebase 초기화와 디스크 홈 캐시 복원을 분리.
- app/bootstrap/startup_flow.dart: 세션·온보딩 읽기, 홈 사전 준비를 화면 밖으로 이동.
- app/routing/startup_destination.dart: 로그인·MBTI·장르·홈 목적지 판정 분리.
- SplashScreen: 시작 결정 결과를 실제 화면으로 연결하는 역할 유지.
- MbtiDetailScreen: 중복 장르 표 대신 GenreCatalog 사용, 첫 장르와 기본 액션 정책 유지.
- FirebaseLlmClient: 실제로 사용하지 않는 App Check를 보호 수단으로 단정한 주석 수정.
- pubspec: 프로젝트 설명과 템플릿 주석 정리. 의존성 버전·에셋 경로는 동일.
- Movie·Genre·Person·ReviewChannel·Video·WatchProvider를 shared/domain/models로 분리했다. KoficPerson은 외부 응답 타입으로 shared/data/kofic에 배치했다. 기존 movie_model.dart는 export 호환 진입점으로 유지한다.

## 확인 수준

Git 상태·이력·경로·문서 링크·소스 참조와 diff를 읽기 전용으로 확인한다. dart format은 코드 서식 변경에만 사용한다. 앱 실행, 빌드, 정적 분석, 자동 테스트와 실제 API 호출 결과는 없다.

현재 문서의 로컬 링크 40개와 Dart package 참조 272개의 대상 파일이 존재함을 확인했다. 런타임 assets·실제 키·pubspec.lock·플랫폼 폴더·중첩 gitlink의 Git 차이는 없었다. 이는 경로 확인이며 컴파일이나 실행 통과를 의미하지 않는다.

## 이어서 반영한 단계

- P2: CatalogRepository·PreferenceRepository와 실제 구현 연결, HTTP 전송·저장·사용자 ID·시계 주입, 실패 반환 확인·복원 시도 규약을 추가했다.
- P3: 기능별 파일을 features로 옮기고 공용 조회·데이터·위젯을 shared로 분류했다. 실제 호출처 이행 후 ApiService·모델 호환 진입점·구형 MBTI 화면·샘플 아바타를 제거했다.
- 활동: 목록·플래그·관람 캘린더 변경을 저장소에 모으고 직렬화했다. 댓글 연속 추가·삭제도 같은 저장 작업 경계를 사용한다.
- 화면: 홈 배너·영화/인물 목록·개봉 안내, 프로필 카드·활동 목록·등급 정책, 상세 조회·댓글 입력을 나눴다.
- 챗봇: 대화 상태 컨트롤러, 정적 규칙 12개, LLM 해석, 후보 확인, 메시지 UI를 분리했다. 초기화 시 이전 서비스의 요청을 새 대화에서 분리했다.
- P4: 기존 테스트 8개를 재분류하고 가짜 API·고정 시계·위험 경계 검사 소스를 추가했다. 현재 검사 파일은 13개이며 실행하지 않았다.
- 문서: 코드 규약·API/사용 흐름·추천 구조·기술 사례·시연 안내·회고·CI 실행 경계를 작성했다. CI 자동 실행은 활성화하지 않았다.
- 저장·런타임 assets·실제 키·의존성 잠금·플랫폼 설정은 유지했다. 인물 생성 파일은 기준 커밋과 비교해 import만 달라진 것을 확인했다.

## 중첩 저장소 연결 정보 보완

원본 저장소와 bundle 백업을 유지하면서 기존 gitlink에 맞는 .gitmodules를 추가했다. 별도 원격 이력을 formal submodule로 명시해 연결 정보 누락을 해소했다. 앱 실행에는 필요하지 않으며 외부 원격 복제는 실행 검증하지 않았다.

## 소스 정리 메모

파일 이동 후 빈 옛 디렉터리를 지우는 셸 작업은 자동 승인 검토에서 정책상 차단됐다. 재시도하지 않고 빈 디렉터리는 그대로 뒀다. Git은 빈 디렉터리를 추적하지 않으므로 업로드 구조에는 포함되지 않는다. 소스 이동·이관표·문서 분류는 적용됐다.

## 남은 확인

외부 이미지·정적 데이터 사용 권리, 개인 기여 정보, 최신 대표 화면 및 두 실테스트 결과는 사용자 확인 대기로 유지한다. 실제 검사·빌드·배포 결과가 없으므로 전체 검증 완료로 표시하지 않는다. 게시 결과는 Git 이력을 따르며 원격 master의 README 개선 커밋 105972a도 작업 브랜치에 반영한다.

## 2026-11-18 README·업로드 정리

원격 README에 추가된 Notion·시연 링크, 2인 팀 구성과 챗봇 담당자 구분을 보존했다. 현재 기능별 구조·디스크 캐시·기기 로컬 활동 저장·13개 검사 소스의 미실행 상태를 반영해 포트폴리오 진입 문서를 개선했다. 작업 브랜치는 codex/portfolio-refactor이며 master 강제 덮어쓰기는 하지 않는다.

