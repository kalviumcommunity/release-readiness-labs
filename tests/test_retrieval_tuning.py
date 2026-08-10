import sys
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "scripts"))

from retrieval_tuning import evaluate_settings, load_queries


class RetrievalTuningTests(unittest.TestCase):
    def test_queries_include_expected_sources(self):
        queries = load_queries(REPO_ROOT / "release" / "retrieval_test_queries.json")
        self.assertGreaterEqual(len(queries), 3)
        for query in queries:
            self.assertTrue(query["expected_sources"], f"missing expected sources for {query['id']}")

    def test_evaluate_settings_returns_multiple_comparisons(self):
        queries = load_queries(REPO_ROOT / "release" / "retrieval_test_queries.json")
        results = evaluate_settings(queries, REPO_ROOT)

        self.assertGreaterEqual(len(results), 2)
        self.assertTrue(all("top_1_hit_rate" in item for item in results))
        self.assertTrue(all("top_k_hit_rate" in item for item in results))
        self.assertTrue(any(item["setting_name"] == "chunk_size_60_k_1" for item in results))
        self.assertTrue(any(item["setting_name"] == "chunk_size_120_k_3" for item in results))
        self.assertGreater(sum(item["top_1_hit_rate"] for item in results), 0.0)
        self.assertGreater(sum(item["top_k_hit_rate"] for item in results), 0.0)


if __name__ == "__main__":
    unittest.main()
