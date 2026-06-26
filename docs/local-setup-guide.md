# Local Setup Guide

## Milestone status

| Milestone | Setup scope | Status |
|---|---|---|
| M0 | Clone repo, review documentation | Completed |
| **M1** | Spring Boot API — validate with `mvn test` | **Available now** |
| M2 | Docker Compose local stack (PostgreSQL + API runtime) | Planned |
| M3+ | Monitoring, Nginx, failure injection, K8s | Planned |

## Prerequisites

**Milestone 1:**

- **Java 21**
- **Maven 3.9+**

**Later milestones:** Docker, Docker Compose, `curl`, `jq`, `kubectl` (optional)

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

## Milestone 2 — Docker Compose (preview)

```bash
# Not yet available
docker compose up -d
docker compose ps
curl -s http://localhost:8080/health
```

PostgreSQL and API runtime will be started as a single local stack.

## Verification checklist (M1)

- [ ] `mvn test` passes without Docker or PostgreSQL
- [ ] Health, ticket list, and 404 tests green in Surefire output

## Verification checklist (M2+)

- [ ] `docker compose up -d` starts API and PostgreSQL
- [ ] `GET /health` returns `status: UP` and `database: UP`
- [ ] `GET /tickets` returns 4 seeded tickets
- [ ] Prometheus targets show `UP` (Milestone 3+)

## Troubleshooting

| Issue | Check |
|---|---|
| `mvn` not found | Install Maven 3.9+; set `JAVA_HOME` to Java 21 |
| Tests fail | Run `mvn clean test`; confirm `application-test.properties` exists |
| `spring-boot:run` cannot connect to DB | Expected without PostgreSQL — use `mvn test` for M1, or wait for M2 Docker Compose |

## Related documents

- [service-overview.md](service-overview.md)
- [architecture-overview.md](architecture-overview.md)
- [monitoring-guide.md](monitoring-guide.md)
