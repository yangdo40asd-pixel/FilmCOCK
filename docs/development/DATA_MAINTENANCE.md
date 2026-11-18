# 데이터와 자산 유지관리

갱신일: 2026-11-17 · 상태: 현재 분류 / 출처 확인 일부 필요

| 자료 | 실행 시 사용 | 관리 방식 |
| --- | --- | --- |
| assets/images | 예 | 기존 경로 보존, pubspec 등록 확인 후 변경 |
| assets/images/mbti | 예 | 16개 MBTI SVG |
| assets/images/tier | 예 | 마이페이지 등급 이미지 |
| assets/data/chatbot_movies.json | 예 | 앱 큐레이션 원본, id·제목·포스터 일치 관리 |
| lib/shared/data/reference/generated/korean_people_data.g.dart | 예 | 생성 인물 데이터, 수작업 코드와 구분 |
| docs/references/design | 아니오 | 과거 화면·참고 이미지·중복 후보 원본 |
| config/api_keys.json | 예, 로컬 파일이 존재할 때 | Git 제외, 배포물에 포함될 수 있음 |

## 데이터 도구

tool/refresh_chatbot_posters.dart는 키를 읽어 TMDB를 조회하고 제목·연도 조건을 확인해 큐레이션 후보를 정리한다. --write는 실제 데이터 변경을 수행한다. 구조 정리 중 자동 실행하지 않는다.

인물 생성 데이터는 생성 표시가 있으나 현재 저장소에서 생성 원본·생성 명령을 확인하지 못했다. 파일을 보존하고 원본 확보 전까지 재생성 가능하다고 주장하지 않는다.

## 중복과 권리

브랜드 원본과 MBTI SVG 중복은 SHA-256으로 비교한다. 원본은 참고 폴더로 보존하고 앱 에셋을 삭제하지 않는다. 파일별 일치 기록은 [디자인 자료 안내](../references/design/README.md)를 참고한다.

포스터·인물 사진·채널 이미지·SVG의 배포 권리를 소유한다고 추정하지 않는다. 출처 URL·제작자·사용 조건은 확인 가능한 자료가 확보되면 기록한다. 외부 서비스 표시 의무와 학교 제출용 공개 범위도 해당 자료를 확인한 뒤 결정한다. 현재 저장소에 일괄 공개 라이선스를 부여하지 않았다.

## 생성 데이터 보존

인물 데이터는 shared/data/reference의 수작업 진입점과 generated 하위 파일로 분리했다. 이번 이동에서 데이터 값은 재생성하지 않고 import 경로만 변경했다. 원본 생성 도구가 확인되지 않아 해당 절차는 계속 확인 필요로 남긴다.

