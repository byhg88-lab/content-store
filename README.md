# MD Templates — 나만의 마크다운 템플릿 아카이브

`templates/` 폴더에 `.md` 파일을 넣고 push 하면, 자동으로 카드가 만들어져 웹사이트에 올라갑니다.
검색 · 카테고리 필터 · 미리보기 · 원클릭 복사 · 다운로드 · 즐겨찾기를 지원합니다.

---

## 1. GitHub Pages에 올리는 법 (처음 한 번만)

1. GitHub에서 새 저장소를 만듭니다. 이름 예: `md-templates` (Public 권장)
2. 이 폴더의 파일 전체를 그 저장소에 업로드합니다.
   - 웹에서 하려면: 저장소 → **Add file → Upload files** → 폴더 통째로 드래그 → Commit
   - 터미널로 하려면:
     ```bash
     git init
     git add .
     git commit -m "첫 커밋: 템플릿 사이트"
     git branch -M main
     git remote add origin https://github.com/<내아이디>/md-templates.git
     git push -u origin main
     ```
3. 저장소 → **Settings → Pages** → *Build and deployment* → **Source: GitHub Actions** 선택
4. 1~2분 뒤 `https://<내아이디>.github.io/md-templates/` 에서 사이트가 열립니다.

> ⚠️ `.github/workflows/pages.yml` 파일이 꼭 함께 올라가야 자동 배포가 됩니다.
> 웹 업로드 시 점(`.`)으로 시작하는 폴더가 빠지기 쉬우니 확인하세요.

---

## 2. 템플릿 추가하는 법 (앞으로 매번)

`templates/` 폴더에 `.md` 파일 하나 추가 → push. 끝입니다.

파일 맨 위에 아래 블록(프론트매터)을 넣으면 카드에 정보가 예쁘게 들어갑니다.

```markdown
---
title: 유튜브 영상 기획안
category: 영상기획
tags: [유튜브, 기획, 촬영]
description: 카드에 한 줄로 보일 설명
---

# 여기서부터 실제 템플릿 내용
```

| 항목 | 필수 | 설명 |
| --- | --- | --- |
| `title` | 선택 | 없으면 첫 번째 `#` 제목을 사용 |
| `category` | 선택 | 없으면 "미분류". 이 값으로 필터 버튼이 자동 생성 |
| `tags` | 선택 | `[a, b, c]` 형식 |
| `description` | 선택 | 카드 설명문 |

파일 이름(확장자 제외)이 그대로 다운로드 파일명이 되니, 영문 소문자·하이픈을 추천합니다.

---

## 3. 내 컴퓨터에서 미리 보기

```bash
python scripts/build_index.py     # 템플릿 목록 갱신
python -m http.server 8000        # 서버 실행
```
브라우저에서 `http://localhost:8000` 접속.

> `index.html`을 더블클릭해서 여는 건 안 됩니다. 브라우저 보안 정책상 `data/index.json`을 못 읽어요.
> 반드시 위처럼 로컬 서버로 여세요.

---

## 4. 폴더 구조

```
├── index.html                  # 사이트 본체 (외부 라이브러리 없음, 단일 파일)
├── templates/                  # ★ 여기에 .md 템플릿을 넣습니다
├── data/index.json             # 자동 생성 (직접 수정 금지)
├── scripts/build_index.py      # templates/ 를 스캔해 index.json 생성
└── .github/workflows/pages.yml # push 시 자동 빌드 + 배포
```

## 5. 자주 바꾸고 싶을 만한 곳

- 사이트 제목·문구: `index.html` 의 `<h1>`, 그 아래 `<p>`
- 로고 글자: `<span class="logo">M</span>`
- 색상: `index.html` 상단 `:root` 의 `--accent`, `--accent-2`
- 기본 테마: `<html lang="ko" data-theme="dark">` → `light`
