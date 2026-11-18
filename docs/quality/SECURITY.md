# 보안과 설정 분류

갱신일: 2026-11-17 · 상태: 코드·Git 분류 / 외부 콘솔 상태 미확인

| 대상 | Git 상태·운영 규칙 |
| --- | --- |
| config/api_keys.json | .gitignore로 제외, 값 출력·문서화 금지 |
| config/api_keys.example.json | 예제만 추적 |
| lib/firebase_options.dart | Firebase 클라이언트 설정으로 추적, 관리자 비밀키와 구분 |
| android/app/google-services.json | Firebase 클라이언트 설정으로 추적 |
| .dart_tool, build, .idea | 생성물·개인 도구 설정으로 제외 |
| 참고 이미지·정적 데이터 | 배포 권리·출처 개별 확인 필요 |
| 과거 Git 이력의 API 자격정보 | 소유자가 폐기·재발급 상태 확인 필요 |

클라이언트 설정 파일 공개와 서비스 사용 권한은 별개다. 인증 제공자·AI Logic 설정·서버 접근 정책·할당량은 콘솔에서 관리한다.

API 키는 Git에서 제외돼도 config 폴더가 앱 에셋에 포함되므로 빌드 결과에서 추출될 수 있다. 비밀 보호가 필요한 호출에는 서버 중계 여부를 따로 검토한다.

FirebaseLlmClient의 App Check 보호 주석을 실제 의존성 상태에 맞게 수정했다. 이번에 App Check를 설치하거나 콘솔 정책을 변경하지 않는다.

외부 LLM에는 시스템 안내·최근 대화·사용자 입력이 전송된다. 개인정보를 포함하는 대화의 취급과 공개 시연 데이터는 별도 안내가 필요하다. 실제 키나 개인 대화를 포트폴리오 캡처에 포함하지 않는다.
