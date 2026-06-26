# Final Validation Checklist

Run before sharing this repository with employers or opening a pull request for portfolio polish. All checks are **local** — no cloud required.

## Application

- [ ] **Maven tests pass** — `cd app/spring-support-api && mvn test`
- [ ] **Package builds** — `mvn package -DskipTests`

## Docker Compose stack

- [ ] **Docker Compose starts** — `docker compose up -d --build` and `docker compose ps` shows healthy services
- [ ] **Health endpoint UP** — `curl -s http://localhost:18081/health` returns `status: UP`, `database: UP`
- [ ] **Tickets endpoint works** — `curl -s http://localhost:18081/tickets` returns data

## Monitoring

- [ ] **Prometheus targets UP** — http://localhost:19090/targets — all scrape jobs healthy
- [ ] **Grafana dashboard exists** — http://localhost:13003 → **Managed Services Operations Overview**
- [ ] **Database metric present** — `support_api_database_up` query returns `1`

## Incident drills

- [ ] **Incident scripts work** — simulate + restore one drill (e.g. database down); alert fires then clears

## SQL troubleshooting

- [ ] **SQL evidence exists** — `database/sql-troubleshooting/evidence/before-index-explain.txt` (Seq Scan ~7 ms) and `after-index-explain.txt` (Bitmap Index Scan ~0.6 ms)

## Kubernetes (optional)

- [ ] **kind deploy validated** — `./scripts/k8s/deploy-kind.sh` completes; `curl http://localhost:18082/health` returns UP

## CI / repository hygiene

- [ ] **Local CI passes** — `./scripts/ci/local-ci-check.sh` prints "All local CI checks passed."
- [ ] **Git status clean** — no unintended uncommitted changes before push

## Quick one-liner (full local CI)

```bash
./scripts/ci/local-ci-check.sh
```

For the recommended review path, see [reviewer-guide.md](reviewer-guide.md).
