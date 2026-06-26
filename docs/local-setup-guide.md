# Local Setup Guide

## Milestone status

| Milestone | Setup scope | Status |
|---|---|---|
| M0 | Clone repo, review documentation | Completed |
| M1 | Spring Boot API — validate with `mvn test` | Completed |
| **M2** | Docker Compose stack: Nginx → API → PostgreSQL | Completed |
| **M3** | Monitoring stack: Prometheus, Grafana, exporters | Completed |
| **M4** | Alert rules, Grafana dashboard, database health metric | Completed |
| **M5** | Controlled incident simulations and drill scripts | Completed |
| **M6** | SQL troubleshooting: EXPLAIN ANALYZE, index evidence | **Completed** |
| **M7** | ITSM documentation: process guides, artifact map | **Completed** |
| M8+ | Kubernetes, CI/CD | Planned |

## Prerequisites

**Milestone 2+ (full stack):**

- **Docker** and **Docker Compose v2**
- **curl** and **jq** — endpoint verification

**Milestone 1 (API tests only):**

- **Java 21**
- **Maven 3.9+**

**Later milestones:** `kubectl` (optional)

## Milestone 1 — validate the API

### Validation command

```bash
cd app/spring-support-api
mvn test
```

`mvn test` uses H2 in PostgreSQL compatibility mode via `src/test/resources/application-test.properties`. It does **not** require Docker or PostgreSQL.

Expected: 4 tests pass (context load, health, tickets list, 404).

### Build (optional)

```bash
cd app/spring-support-api
mvn clean package -DskipTests
```

### Manual runtime — not required for Milestone 1

`mvn spring-boot:run` uses PostgreSQL at `jdbc:postgresql://localhost:5432/supportdb` (see `application.properties`). You must provide your own PostgreSQL instance with database `supportdb` and matching credentials.

**Milestone 2** will provide PostgreSQL and the API together through Docker Compose — that is the supported path for running the application locally.

> H2 is for automated tests only. Do not use `spring-boot:run` with the test profile as a manual run path.

## Milestone 2 — run the full stack with Docker Compose

The stack runs three containers: `msol-nginx` (reverse proxy), `msol-support-api` (Spring Boot), and `msol-postgres` (PostgreSQL with a persistent volume).

### Start

```bash
docker compose up -d --build
docker compose ps
```

The API waits for PostgreSQL to pass its `pg_isready` health check before starting. First build downloads Maven dependencies and may take a few minutes.

### Verify

```bash
# API direct (bypasses proxy — for troubleshooting)
curl -s http://localhost:18080/health | jq .

# Through the Nginx reverse proxy (customer entry point)
curl -s http://localhost:18081/health | jq .
curl -s http://localhost:18081/tickets | jq .
```

Expected: `status: UP`, `database: UP`, and 4 seeded tickets.

PostgreSQL is reachable from the host at `localhost:15434` (e.g. `psql -h localhost -p 15434 -U supportuser supportdb`). Inside the Docker network the API still connects via `jdbc:postgresql://postgres:5432/supportdb`.

### Monitoring (Milestone 3)

`docker compose up -d` also starts the monitoring stack. Host ports:

| Component | Host port | URL |
|---|---|---|
| Prometheus | 19090 | http://localhost:19090 |
| Grafana | 13003 | http://localhost:13003 (login `admin` / `admin`) |
| Alertmanager | 19093 | http://localhost:19093 |
| Node Exporter | 19100 | http://localhost:19100/metrics |
| cAdvisor | 18084 | http://localhost:18084 |

Verify monitoring:

```bash
curl -s http://localhost:19090/-/ready                  # Prometheus ready
curl -s http://localhost:19093/-/ready                  # Alertmanager ready
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:13003/login   # Grafana 200
curl -s http://localhost:18080/actuator/prometheus | head   # app metrics exposed
curl -s 'http://localhost:19090/api/v1/query?query=up' | jq '.data.result[] | {job:.metric.job, up:.value[1]}'
```

Then open http://localhost:19090/targets — every job should be **UP**. See [monitoring-guide.md](monitoring-guide.md) for useful queries.

### Monitoring alerts and dashboard (Milestone 4)

```bash
# Validate Prometheus alert rules
docker compose exec prometheus promtool check rules /etc/prometheus/rules/managed-services-alerts.yml
curl -s http://localhost:19090/api/v1/rules | jq '.data.groups[].name'

# Custom database health metric (updated on each /health check)
curl -s 'http://localhost:19090/api/v1/query?query=support_api_database_up' | jq .

# Grafana dashboard: http://localhost:13003 → Dashboards → Managed Services
#   "Managed Services Operations Overview"
```

## Verification checklist (M4, alerts and dashboard)

- [ ] `promtool check rules` passes for `managed-services-alerts.yml`
- [ ] http://localhost:19090/alerts lists 7 rules (inactive when healthy)
- [ ] `support_api_database_up` returns `1` in Prometheus
- [ ] Grafana dashboard **Managed Services Operations Overview** loads with data
- [ ] All 8 dashboard panels show values (may need a few scrape cycles)

### Inspect

```bash
docker compose logs -f spring-support-api
docker compose logs -f nginx
docker compose exec postgres psql -U supportuser -d supportdb -c "SELECT count(*) FROM support_tickets;"
```

### Stop

```bash
docker compose down       # stop containers, keep database volume
docker compose down -v    # stop and remove the database volume (fresh start)
```

## Verification checklist (M2)

- [ ] `docker compose ps` shows all three containers healthy
- [ ] `GET http://localhost:18080/health` returns `status: UP`, `database: UP`
- [ ] `GET http://localhost:18081/health` (via Nginx) returns the same
- [ ] `GET http://localhost:18081/tickets` returns 4 seeded tickets
- [ ] PostgreSQL reachable from host at `localhost:15434`
- [ ] Data persists across `docker compose down` then `up` (volume retained)

## Verification checklist (M3, monitoring)

- [ ] Prometheus UI reachable at http://localhost:19090
- [ ] All scrape targets UP at http://localhost:19090/targets
- [ ] Grafana login works at http://localhost:13003 (`admin` / `admin`)
- [ ] Alertmanager UI reachable at http://localhost:19093
- [ ] `up{job="spring-support-api"}` returns 1 in Prometheus

- [ ] All 8 dashboard panels show values (may need a few scrape cycles)

## Milestone 5 — incident simulation drills

**Prerequisites:** full stack running (`docker compose up -d --build`)

### Simulation rules

- Run **only one** incident simulation at a time.
- Always run the matching **restore script** before starting the next simulation.
- HTTP 500 simulation requires baseline health `status: UP` and `database: UP` — otherwise Nginx may return 502/504 instead of application HTTP 500.

### Database down (INC-001)

```bash
./scripts/incidents/simulate-database-down.sh
# Check http://localhost:19090/alerts — SupportApiDatabaseDown
./scripts/incidents/restore-database-down.sh
```

### HTTP 500 errors (INC-002)

```bash
./scripts/incidents/simulate-http-500.sh
# Wait up to 2m — SupportApiHighErrorRate may fire
# Alert clears when 5xx rate returns to 0
```

### Bad env / container unhealthy (INC-003)

```bash
./scripts/incidents/simulate-bad-env-restart-loop.sh
docker compose ps   # msol-support-api unhealthy
./scripts/incidents/restore-bad-env-restart-loop.sh
```

## Verification checklist (M5)

- [ ] Database drill: health shows `DEGRADED` then recovers to `UP`
- [ ] HTTP 500 drill: `/simulate/http-500` returns 500 with JSON error body
- [ ] Bad-env drill: container unhealthy with wrong datasource URL
- [ ] Restore scripts return stack to healthy state
- [ ] Incident records INC-001–003 match commands used in drill
- [ ] Alerts visible at http://localhost:19090/alerts during drill

## Milestone 6 — SQL slow query investigation

**Prerequisites:** full stack running (`docker compose up -d`)

```bash
./scripts/sql/run-slow-query-investigation.sh
```

The script creates demo table `support_ticket_events` (~100k rows), runs `EXPLAIN ANALYZE` before and after index fix, and saves evidence to:

- `database/sql-troubleshooting/evidence/before-index-explain.txt`
- `database/sql-troubleshooting/evidence/after-index-explain.txt`

Optional cleanup:

```bash
docker compose exec -T postgres psql -U supportuser -d supportdb \
  < database/sql-troubleshooting/05-cleanup-slow-query-demo.sql
```

## Verification checklist (M6)

- [ ] Script completes without error
- [ ] Before evidence shows sequential scan
- [ ] After evidence shows index scan on `idx_support_ticket_events_customer_event_created`
- [ ] Execution time improved in after vs before
- [ ] PRB-001 and CHG-001 reference evidence paths

## Verification checklist (M1, no Docker)

- [ ] `mvn test` passes without Docker or PostgreSQL
- [ ] Health, ticket list, and 404 tests green in Surefire output

## Troubleshooting

| Issue | Check |
|---|---|
| `mvn` not found | Install Maven 3.9+; set `JAVA_HOME` to Java 21 |
| Tests fail | Run `mvn clean test`; confirm `application-test.properties` exists |
| API container unhealthy | `docker compose logs spring-support-api`; confirm `msol-postgres` is healthy first |
| `database: DOWN` in `/health` | PostgreSQL not ready or wrong credentials; check `docker compose ps` and `logs postgres` |
| Port 18080/18081/15434 in use | `ss -tlnp \| grep -E '18080\|18081\|15434'` — stop the conflicting process |
| Monitoring port in use | `ss -tlnp \| grep -E '19090\|13003\|19093\|19100\|18084'` — stop the conflicting process |
| Prometheus target DOWN | `docker compose logs prometheus`; confirm the target container is healthy and on `msol-net` |
| Stale data after schema change | `docker compose down -v` to reset the volume, then `up -d --build` |

## Related documents

- [service-overview.md](service-overview.md)
- [architecture-overview.md](architecture-overview.md)
- [monitoring-guide.md](monitoring-guide.md)
