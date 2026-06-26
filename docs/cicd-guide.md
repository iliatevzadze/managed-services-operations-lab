# CI/CD Guide (Milestone 9)

## Purpose

Automated **validation gates** that run on every push and pull request, so
changes are checked before they are accepted. CI proves the application tests
pass, the container builds, the Docker Compose file is valid, and the Kubernetes
manifests are well-formed — the same checks a Managed Services team relies on to
keep a customer platform stable.

> This is **CI validation only**. No cloud deployment, no registry push, no
> secrets, and no workflows that require external accounts.

## Workflows

All workflows live in [`.github/workflows/`](../.github/workflows/) and trigger
on `push` and `pull_request`.

| Workflow | File | Job | What it checks |
|---|---|---|---|
| **Java CI** | `java-ci.yml` | `test` | `mvn test` (H2-backed unit tests) and `mvn package -DskipTests` on Java 21 (Temurin, Maven cache) |
| **Docker Compose CI** | `docker-compose-ci.yml` | `compose-validate` | `docker compose version`, `docker compose config`, and `docker build` of the API image |
| **Kubernetes Manifests CI** | `k8s-ci.yml` | `k8s-validate` | Installs stable `kubectl`, then `kubectl apply --dry-run=client` over `k8s/base/` (whole directory + each file) |

### Why client-side dry-run for Kubernetes

`kubectl apply --dry-run=client` parses and validates manifests **locally**,
without contacting an API server. This means manifest structure, required
fields, and basic schema are checked **without creating a cluster** — fast, free,
and reliable in CI.

## What CI intentionally does NOT do

- **No `docker compose up`** — keeps CI fast, stable, and free; runtime drills
  stay local (Docker Compose) and on kind (Milestone 8).
- **No image push to a registry** — images are built to prove they compile, then
  discarded.
- **No cluster creation** — Kubernetes validation is client-side only.
- **No cloud deployment, no secrets, no paid services.**

## Local validation

Run the same checks locally before pushing:

```bash
./scripts/ci/local-ci-check.sh
```

It runs: Java tests + package, `docker compose config`, the API image build,
shell-script syntax checks (`bash -n`), and — if `kubectl` is installed — the
Kubernetes manifest dry-run. If `kubectl` is missing it prints a skip note and
continues.

## How this maps to Managed Services / Exxeta

| CI gate | Managed Services value |
|---|---|
| Java tests | Catch application regressions before they reach a customer environment |
| Image build | Confirm the deployable artifact is reproducible |
| Compose config | Validate the documented local stack stays runnable |
| K8s manifest dry-run | Catch deployment misconfiguration before a rollout |
| Local CI script | Shift-left: engineers validate before review, reducing failed pipelines |

This demonstrates **change validation discipline** — the same principle behind
the change-management process: verify before you accept.

## Badges

After pushing to GitHub, replace `USERNAME` in the README badge URLs with the
repository owner. Badges reflect the latest run on the default branch.

## Troubleshooting common CI failures

| Symptom | Likely cause | Fix |
|---|---|---|
| `mvn test` fails in Java CI | Test regression or missing `application-test.properties` | Reproduce with `./scripts/ci/local-ci-check.sh`; run `mvn clean test` |
| Maven cache miss / slow build | First run or `pom.xml` changed | Expected; cache repopulates on next run |
| `docker compose config` errors | Invalid YAML or undefined variable in `docker-compose.yml` | Run `docker compose config` locally to see the parsed output |
| `docker build` fails | Dockerfile or dependency issue | Build locally: `docker build -t test app/spring-support-api` |
| `kubectl apply --dry-run=client` fails | Manifest schema/field error in `k8s/base/` | Validate the named file locally with the same command |
| kubectl install step fails | Transient network issue fetching the stable release | Re-run the job |

## Related documents

- [local-setup-guide.md](local-setup-guide.md)
- [architecture-overview.md](architecture-overview.md)
- [change-management-process.md](change-management-process.md)
- [../k8s/README.md](../k8s/README.md)
