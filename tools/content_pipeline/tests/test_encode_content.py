import sys
import unittest
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parents[1]))
from encode_content import encode_article, make_index


class EncodeContentTest(unittest.TestCase):
    def setUp(self):
        self.now = datetime(2026, 7, 31, tzinfo=timezone.utc)
        self.raw = {"category": "Medical", "language": "zh_TW", "title": "Test article", "content": "One paragraph.\n\nTwo paragraph.", "link": "https://example.org/a"}

    def test_current_content_item_shape_is_encoded(self):
        article = encode_article(self.raw, self.now)
        self.assertEqual(article["category"], "medical")
        self.assertEqual(article["language"], "zh-TW")
        self.assertEqual(article["download"]["coin_cost"], 2)
        self.assertEqual(len(article["body"]), 2)
        self.assertEqual(article["version"], 1)

    def test_index_excludes_full_body(self):
        article = encode_article(self.raw, self.now)
        entry = make_index([article], self.now)["articles"][0]
        self.assertNotIn("body", entry)
        self.assertEqual(entry["coin_cost"], 2)

    def test_invalid_source_is_rejected(self):
        self.raw["link"] = "not-a-url"
        with self.assertRaises(ValueError):
            encode_article(self.raw, self.now)


if __name__ == "__main__":
    unittest.main()
