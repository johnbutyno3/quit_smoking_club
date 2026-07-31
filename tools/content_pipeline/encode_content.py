"""Encode importer output into QSC's versioned article contract."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import unicodedata
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

CATEGORY_MAP = {
    "medical": "medical", "stories": "story", "story": "story",
    "guide": "guide", "games": "game", "game": "game",
    "music": "music", "youtube": "video", "video": "video",
}
DEFAULT_COIN_COST = {"medical": 2, "story": 1, "guide": 2, "game": 1, "music": 1, "video": 1}


def _text(value: Any) -> str:
    return " ".join(str(value or "").replace("\r\n", "\n").split())


def _slug(value: str) -> str:
    normalized = unicodedata.normalize("NFKD", value).encode("ascii", "ignore").decode().lower()
    normalized = re.sub(r"[^a-z0-9]+", "-", normalized).strip("-")
    if normalized:
        return normalized
    # Chinese and other non-Latin titles may not transliterate through the
    # standard library. Keep their ID deterministic instead of collapsing all
    # such titles to "article".
    return f"article-{hashlib.sha1(value.encode('utf-8')).hexdigest()[:10]}"


def _language(value: Any) -> str:
    raw = str(value or "all").replace("_", "-").strip()
    if raw.lower() == "all":
        return "en"
    parts = raw.split("-", 1)
    return parts[0].lower() if len(parts) == 1 else f"{parts[0].lower()}-{parts[1].upper()}"


def _paragraphs(value: Any) -> list[dict[str, str]]:
    chunks = [" ".join(chunk.split()) for chunk in re.split(r"\n\s*\n", str(value or ""))]
    return [{"type": "paragraph", "text": chunk} for chunk in chunks if chunk]


def encode_article(raw: dict[str, Any], now: datetime | None = None) -> dict[str, Any]:
    title = _text(raw.get("title"))
    body = _paragraphs(raw.get("body", raw.get("content", "")))
    if not title or not body:
        raise ValueError("Each article requires a non-empty title and body/content.")
    category = CATEGORY_MAP.get(_text(raw.get("category")).lower())
    if category is None:
        raise ValueError("Unsupported category. Use Medical, Stories, Guide, Games, Music, YouTube, or Video.")
    source_url = _text(raw.get("source_url", raw.get("link")))
    if not source_url.startswith(("https://", "http://")):
        raise ValueError("Each article requires an http(s) source URL.")
    timestamp = (now or datetime.now(timezone.utc)).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    full_text = "\n\n".join(block["text"] for block in body)
    preview_length = max(1, round(len(full_text) * 0.15))
    supplied_id = _text(raw.get("id"))
    article_id = _slug(supplied_id) if supplied_id else f"{category}-{_language(raw.get('language'))}-{_slug(title)}"
    return {
        "schema_version": 1, "id": article_id, "category": category,
        "language": _language(raw.get("language")), "title": title,
        "summary": _text(raw.get("summary")) or full_text[:160], "body": body,
        "source": {"name": _text(raw.get("source_name")), "url": source_url},
        "preview": {"text": full_text[:preview_length], "read_percent": 15},
        "download": {"coin_cost": int(raw.get("coin_cost", DEFAULT_COIN_COST[category]))},
        "version": int(raw.get("version", 1)), "status": _text(raw.get("status")) or "draft",
        "published_at": raw.get("published_at") or timestamp, "updated_at": timestamp,
    }


def make_index(articles: list[dict[str, Any]], now: datetime | None = None) -> dict[str, Any]:
    timestamp = (now or datetime.now(timezone.utc)).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    return {"schema_version": 1, "generated_at": timestamp, "articles": [
        {"id": a["id"], "category": a["category"], "language": a["language"], "title": a["title"],
         "summary": a["summary"], "preview": a["preview"]["text"], "coin_cost": a["download"]["coin_cost"],
         "version": a["version"], "status": a["status"]} for a in articles
    ]}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path)
    parser.add_argument("--output-dir", type=Path, required=True)
    args = parser.parse_args()
    raw = json.loads(args.input.read_text(encoding="utf-8"))
    records = raw if isinstance(raw, list) else [raw]
    articles = [encode_article(item) for item in records]
    if len({article["id"] for article in articles}) != len(articles):
        raise ValueError("Duplicate article IDs in input.")
    article_dir = args.output_dir / "articles"
    article_dir.mkdir(parents=True, exist_ok=True)
    for article in articles:
        (article_dir / f"{article['id']}.json").write_text(json.dumps(article, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    (args.output_dir / "content_index.json").write_text(json.dumps(make_index(articles), ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
