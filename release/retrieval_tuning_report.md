# Retrieval tuning report

## Test queries

- q1: production deployment approval -> expected sources: release/approvals.yml, release/release-summary.yml
- q2: kubernetes deployment image tag -> expected sources: deployment/kubernetes/deployment.yaml, release/deployment-config.yml
- q3: health endpoint api status -> expected sources: app/server.js, README.md

## Compared settings

- chunk_size_60_k_1: chunk size 60, top_k 1, top_1 hit rate 0.333, top_k hit rate 0.333
- chunk_size_60_k_3: chunk size 60, top_k 3, top_1 hit rate 0.333, top_k hit rate 1.0
- chunk_size_120_k_3: chunk size 120, top_k 3, top_1 hit rate 0.333, top_k hit rate 1.0

## Best setting

- Chosen setting: chunk_size_60_k_3
- Reason: it achieved the highest top_k hit rate (1.0) while keeping a solid top_1 hit rate (0.333).
