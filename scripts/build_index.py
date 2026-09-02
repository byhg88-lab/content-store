#!/usr/bin/env python3
"""templates/ 폴더의 .md 파일을 스캔해 data/index.json 을 생성합니다.

사용법:  python scripts/build_index.py
md 파일 맨 위에 아래처럼 YAML 프론트매터를 넣어주세요.

---
title: 유튜브 기획안
category: 영상기획
tags: [유튜브, 숏폼, 기획]
description: 유튜브 영상 한 편을 기획할 때 쓰는 체크리스트형 템플릿
---
"""
import json, re, sys, datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TPL_DIR = ROOT / "templates"
OUT = ROOT / "data" / "index.json"

FM_RE = re.compile(r"^---\s*\n(.*?)\n---\s*\n?", re.S)


def parse_scalar(v: str):
    v = v.strip()
    if v.startswith("[") and v.endswith("]"):
        inner = v[1:-1].strip()
        if not inner:
            return []
        return [x.strip().strip("'\"") for x in inner.split(",") if x.strip()]
    return v.strip("'\"")


def parse_frontmatter(text: str):
    """의존성 없는 아주 단순한 YAML 프론트매터 파서 (key: value, 리스트 지원)."""
    m = FM_RE.match(text)
    if not m:
        return {}, text
    meta, body = {}, text[m.end():]
    key = None
    for line in m.group(1).splitlines():
        if not line.strip() or line.strip().startswith("#"):
            continue
        if line.lstrip().startswith("- ") and key:
            meta.setdefault(key, [])
            if isinstance(meta[key], list):
                meta[key].append(line.lstrip()[2:].strip().strip("'\""))
            continue
        if ":" in line:
            k, _, v = line.partition(":")
            key = k.strip()
            meta[key] = parse_scalar(v) if v.strip() else []
    return meta, body


def first_heading(body: str, fallback: str) -> str:
    for line in body.splitlines():
        if line.startswith("#"):
            return line.lstrip("#").strip()
    return fallback


def main() -> int:
    if not TPL_DIR.exists():
        print(f"[!] templates 폴더가 없습니다: {TPL_DIR}")
        return 1

    items = []
    for p in sorted(TPL_DIR.rglob("*.md")):
        raw = p.read_text(encoding="utf-8")
        meta, body = parse_frontmatter(raw)
        tags = meta.get("tags", [])
        if isinstance(tags, str):
            tags = [t.strip() for t in tags.split(",") if t.strip()]
        rel = p.relative_to(ROOT).as_posix()
        items.append({
            "id": p.stem,
            "title": meta.get("title") or first_heading(body, p.stem),
            "category": meta.get("category") or "미분류",
            "tags": tags,
            "description": meta.get("description", ""),
            "author": meta.get("author", ""),
            "updated": meta.get("updated") or datetime.date.fromtimestamp(p.stat().st_mtime).isoformat(),
            "path": rel,
            "body": body.strip(),
            "chars": len(body.strip()),
        })

    cats = sorted({i["category"] for i in items})
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps({
        "generated": datetime.datetime.now().isoformat(timespec="seconds"),
        "count": len(items),
        "categories": cats,
        "templates": items,
    }, ensure_ascii=False, indent=2), encoding="utf-8")

    print(f"[ok] 템플릿 {len(items)}개 / 카테고리 {len(cats)}개 -> {OUT.relative_to(ROOT)}")
    for i in items:
        print(f"     - [{i['category']}] {i['title']}  ({i['path']})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
