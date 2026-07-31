# QSC content pipeline

This folder turns an Importer's raw article output into the stable content
format used by Quit Smoking Club.  It deliberately has no Flutter or database
dependency: the result can be reviewed before it is uploaded to Supabase.

## Input accepted from the current importer

The encoder accepts either one JSON object or a JSON array.  These fields are
compatible with the project's existing `ContentItem` shape:

```json
{
  "category": "Medical",
  "language": "zh-TW",
  "title": "戒菸後的身體變化",
  "content": "第一段。\n\n第二段。",
  "link": "https://example.org/article"
}
```

`body`, `source_url`, `source_name`, `summary`, `coin_cost`, `version`, and
`id` are optional.  The encoder preserves a supplied `id`; otherwise it makes
a stable ID from category, language, and title.

## Run

From the repository root:

```powershell
python tools/content_pipeline/encode_content.py tools/content_pipeline/examples/raw_articles.json --output-dir build/content
```

The command produces:

- `build/content/articles/<article-id>.json`: the full article downloaded only
  after the user unlocks it.
- `build/content/content_index.json`: lightweight list metadata, including
  preview, price, and current version.  This is the only file the App needs to
  load for browsing.

Run `python -m unittest discover -s tools/content_pipeline/tests` to validate
the encoder behaviour.

## Supabase hand-off

Store index fields in an `article_index` table and full JSON in an
`article_content` table keyed by `article_id` and `version`.  The App first
loads the index; after a coin transaction succeeds it requests that article's
current content only, then caches the returned version locally.  A later index
refresh tells the App whether a cached article needs an update.

The JSON Schemas in `schemas/` are the contract for that upload step.
