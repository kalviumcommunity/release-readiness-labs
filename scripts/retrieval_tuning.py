import json
import re
from pathlib import Path
from typing import Dict, List, Tuple

REPO_ROOT = Path(__file__).resolve().parents[1]


def load_queries(path: Path) -> List[Dict[str, object]]:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def build_corpus(root: Path) -> List[Dict[str, str]]:
    root = root.resolve()
    corpus_files = [
        root / "README.md",
        root / "app" / "server.js",
        root / "deployment" / "kubernetes" / "deployment.yaml",
        root / "release" / "deployment-config.yml",
        root / "release" / "approvals.yml",
        root / "release" / "release-summary.yml",
    ]

    documents: List[Dict[str, str]] = []
    for path in corpus_files:
        if path.exists():
            text = path.read_text(encoding="utf-8")
            relative_path = path.relative_to(root).as_posix()
            documents.append({"id": relative_path, "text": text})
    return documents


def simple_tokenize(text: str) -> List[str]:
    return re.findall(r"[a-z0-9]+", text.lower())


def chunk_text(text: str, size: int) -> List[str]:
    tokens = simple_tokenize(text)
    if not tokens:
        return []
    chunks: List[str] = []
    for start in range(0, len(tokens), size):
        chunk_tokens = tokens[start : start + size]
        if chunk_tokens:
            chunks.append(" ".join(chunk_tokens))
    return chunks


def build_chunks(documents: List[Dict[str, str]], chunk_size: int) -> List[Dict[str, str]]:
    chunks: List[Dict[str, str]] = []
    for document in documents:
        document_chunks = chunk_text(document["text"], chunk_size)
        for index, chunk_text_value in enumerate(document_chunks):
            chunks.append(
                {
                    "id": f"{document['id']}::chunk-{index}",
                    "source": document["id"],
                    "text": chunk_text_value,
                }
            )
    return chunks


def score_query(query: str, chunk: Dict[str, str]) -> float:
    query_tokens = set(simple_tokenize(query))
    chunk_tokens = set(simple_tokenize(chunk["text"]))
    if not query_tokens:
        return 0.0
    overlap = query_tokens & chunk_tokens
    return len(overlap) / len(query_tokens)


def retrieve(chunks: List[Dict[str, str]], query: str, top_k: int) -> List[Dict[str, object]]:
    scored = []
    for chunk in chunks:
        scored.append((score_query(query, chunk), chunk))
    scored.sort(key=lambda item: item[0], reverse=True)
    return [{"chunk_id": chunk["id"], "source": chunk["source"], "score": score} for score, chunk in scored[:top_k]]


def evaluate_query(query: Dict[str, object], chunks: List[Dict[str, str]], top_k: int) -> Dict[str, object]:
    retrieved = retrieve(chunks, str(query["query"]), top_k)
    expected_sources = {str(source) for source in query["expected_sources"]}
    retrieved_sources = {item["source"] for item in retrieved}
    top_1_hit = 1 if expected_sources & {item["source"] for item in retrieved[:1]} else 0
    top_k_hit = 1 if expected_sources & retrieved_sources else 0
    return {
        "query_id": query["id"],
        "top_1_hit": top_1_hit,
        "top_k_hit": top_k_hit,
        "retrieved_sources": sorted(retrieved_sources),
    }


def evaluate_settings(queries: List[Dict[str, object]], root: Path) -> List[Dict[str, object]]:
    documents = build_corpus(root)
    settings = [
        {"setting_name": "chunk_size_60_k_1", "chunk_size": 60, "top_k": 1},
        {"setting_name": "chunk_size_60_k_3", "chunk_size": 60, "top_k": 3},
        {"setting_name": "chunk_size_120_k_3", "chunk_size": 120, "top_k": 3},
    ]
    results: List[Dict[str, object]] = []
    for setting in settings:
        chunks = build_chunks(documents, setting["chunk_size"])
        evaluation_rows = [evaluate_query(query, chunks, setting["top_k"]) for query in queries]
        top_1_hits = sum(row["top_1_hit"] for row in evaluation_rows)
        top_k_hits = sum(row["top_k_hit"] for row in evaluation_rows)
        results.append(
            {
                "setting_name": setting["setting_name"],
                "chunk_size": setting["chunk_size"],
                "top_k": setting["top_k"],
                "top_1_hit_rate": round(top_1_hits / len(queries), 3),
                "top_k_hit_rate": round(top_k_hits / len(queries), 3),
                "query_results": evaluation_rows,
            }
        )
    return results


def write_report(queries: List[Dict[str, object]], results: List[Dict[str, object]], root: Path) -> None:
    best_setting = max(results, key=lambda item: (item["top_k_hit_rate"], item["top_1_hit_rate"]))
    lines = [
        "# Retrieval tuning report",
        "",
        "## Test queries",
        "",
    ]
    for query in queries:
        lines.append(f"- {query['id']}: {query['query']} -> expected sources: {', '.join(query['expected_sources'])}")

    lines.extend([
        "",
        "## Compared settings",
        "",
    ])
    for item in results:
        lines.append(
            f"- {item['setting_name']}: chunk size {item['chunk_size']}, top_k {item['top_k']}, top_1 hit rate {item['top_1_hit_rate']}, top_k hit rate {item['top_k_hit_rate']}"
        )

    lines.extend([
        "",
        "## Best setting",
        "",
        f"- Chosen setting: {best_setting['setting_name']}",
        f"- Reason: it achieved the highest top_k hit rate ({best_setting['top_k_hit_rate']}) while keeping a solid top_1 hit rate ({best_setting['top_1_hit_rate']}).",
    ])

    report_path = root / "release" / "retrieval_tuning_report.md"
    report_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    root = REPO_ROOT
    queries_path = root / "release" / "retrieval_test_queries.json"
    queries = load_queries(queries_path)
    results = evaluate_settings(queries, root)
    report_path = root / "release" / "retrieval_tuning_results.json"
    report_path.write_text(json.dumps(results, indent=2), encoding="utf-8")
    write_report(queries, results, root)
    print(json.dumps(results, indent=2))


if __name__ == "__main__":
    main()
