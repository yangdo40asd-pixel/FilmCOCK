# 외부 API와 오류 경계

갱신일: 2026-11-17 · 상태: 현재 코드 기준 / 라이브 연동 미검증

| 계층 | 책임 |
| --- | --- |
| core/network/HttpTransport | 인증 헤더·단일 요청 제한·네트워크 오류 변환, HTTP client 주입 |
| shared/data/tmdb | 영화·인물 API 응답 파싱 |
| shared/data/kofic | 국내 박스오피스와 영화인 조회·TMDB 연결 |
| shared/data/search | 영화·인물 검색·자동완성·참조 데이터 결합 |
| shared/data/catalog/RemoteCatalogRepository | 전용 구현을 CatalogRepository에 연결 |
| shared/domain/repositories/CatalogRepository | 화면·추천·챗봇이 요구하는 조회 계약 |

TMDB 읽기 토큰이 있으면 Bearer 헤더를 사용하고 URL의 api_key를 제거한다. KOFIC 키는 해당 API 요청에 사용한다. 외부 예외는 공통 사용자 안내로 변환하며 코드 경로를 옮긴다고 호출 공급자나 응답 필터를 바꾸지 않는다.

API 한 요청 제한은 기본 15초다. KOFIC 조회·TMDB 후보 매칭처럼 여러 요청을 조합하는 작업의 총 시간과는 다르다. 홈은 섹션별 실패와 마지막 정상 캐시를 사용한다.

추천과 챗봇·검색 컨트롤러의 단위 검사는 가짜 CatalogRepository를 주입한다. 실제 API 응답이 필요한 smoke 도구는 사용자 실행 영역이다. 서비스 콘솔의 할당량·요금·키 폐기 상태는 이번 소스 작업에서 확인하지 않았다.
