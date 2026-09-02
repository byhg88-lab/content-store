# 노션 연동 & 구조

호스티드 Notion MCP(OAuth)로 연결. **실제 워크스페이스·페이지 URL·데이터소스 ID·계정 정보는
`reference/notion-setup.local.md` 에만 둡니다** (git에 올리지 않음). 이 문서는 구조와 매핑 규칙만 설명합니다.

## 노션 구조 — 허브 페이지 아래 3개 DB

**허브: 「희림 콘텐츠 파이프라인」** (URL은 local 파일 참조)
그 아래에:

### 1) 건축 이슈 수집  (issue DB)
- 컬럼: 제목(Title) / 요약(text) / 분류(select: 설계·디자인·기술·공법·프로젝트·수주·제도·법규·업계동향) /
  지역(select: 국내·해외) / 발행일(date) / 원문(url) / 신뢰도(select: 상·중) /
  콘텐츠 각도(text) / 상태(select: 신규·제작예정·제작완료·보류) / 수집일(date)

### 2) 콘텐츠 원고  (draft DB)
- 컬럼: 제목(Title) / 유형(select: 블로그·유튜브) /
  상태(select: 초안·검토중·수정요청·발행예정·발행완료) /
  대상 이슈(relation → 건축 이슈 수집) / 작성일(date) / 발행예정일(date) / 로컬 파일(text)
- 원고 본문은 각 행(페이지)의 본문에 마크다운으로 저장

### 3) 주간 다이제스트  (log DB)
- 컬럼: 제목(Title) / 주간 시작일(date) / 이슈 수(number) / 유망 주제 3(text) / 로컬 파일(text)

> 각 DB의 `data_source_id` 는 `reference/notion-setup.local.md` 에 있습니다.
> Claude는 노션 작업 전에 그 파일을 읽어 ID를 확인하세요.

## 속성 매핑

### notion-log → `건축 이슈 수집`
weekly-digest 항목 → 노션 속성
- 제목 → 제목 / 한 줄 요약 → 요약 / 카테고리 → 분류 / 국내·해외 → 지역 /
  발행일 → 발행일 / 원문 링크 → 원문 / 신뢰도 → 신뢰도 / 콘텐츠 각도 → 콘텐츠 각도
- (고정) 상태 = 신규, 수집일 = 실행일
- **중복 방지**: 같은 `원문` URL이 이미 있으면 건너뜀
- 분류 정규화: 다이제스트의 "발주·사업관리·CM/감리" → "제도·법규"

### notion-log → `주간 다이제스트` (1행 추가)
- 제목 = "YYYY-MM-DD 주간 (스캔 기간)" / 주간 시작일 = 그 주 월요일 /
  이슈 수 = 통과 이슈 개수 / 유망 주제 3 = 다이제스트의 "유망 3개" / 로컬 파일 = outputs 경로

### blog-draft / youtube-script → `콘텐츠 원고` (1행 추가)
- 제목 = 확정 제목 / 유형 = 블로그 or 유튜브 / 상태 = 초안 /
  대상 이슈 = 참고한 `건축 이슈 수집` 행 연결 / 작성일 = 오늘 / 로컬 파일 = outputs 경로
- 원고 본문(마크다운)을 그 행의 페이지 본문에 넣는다
- 동시에 `건축 이슈 수집`의 해당 이슈 상태를 "제작완료"로 변경

## 처음 설정하는 사람용 (다른 워크스페이스에 새로 구축할 때)
1. `claude mcp add --transport http notion https://mcp.notion.com/mcp` → Claude Code에서 `/mcp` → notion → Authenticate
2. 위 3개 DB를 만들거나 Claude에게 "허브 페이지와 3개 DB를 만들어줘"라고 요청
3. 생성된 URL·data_source_id를 `reference/notion-setup.local.md` 에 기록

## 연결이 끊겼을 때
`claude mcp list` 로 확인. 재인증은 `/mcp` → notion → Authenticate.
MCP가 안 되면 `outputs/` 에 표로 저장하고 사용자에게 알림.
