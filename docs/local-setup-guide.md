# Local Setup Guide

## Milestone status

| Milestone | Setup scope | Status |
|---|---|---|
| M0 | Clone repo, review documentation | Completed |
| M1 | Spring Boot API — validate with `mvn test` | Completed |
| **M2** | Docker Compose stack: Nginx → API → PostgreSQL | **Available now** |
| M3+ | Monitoring, failure injection, K8s | Planned |

## Prerequisites

**Milestone 2 (full stack):**

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
| Stale data after schema change | `docker compose down -v` to reset the volume, then `up -d --build` |

## Related documents

- [service-overview.md](service-overview.md)
- [architecture-overview.md](architecture-overview.md)
- [monitoring-guide.md](monitoring-guide.md)
