# Resume Bullets — Managed Services Operations Lab

Practical capability bullets for CV, LinkedIn, or cover letter. Each reflects work I demonstrated in this **local portfolio lab** — not claimed production tenure.

---

- Built a **local Managed Services operations lab** for a containerized Spring Boot API: incident/problem/change records, runbooks, and ITIL-aligned process documentation.

- Implemented **monitoring-driven incident response** with Prometheus alert rules, Grafana operations dashboard, and controlled drill scripts — detect → investigate → restore → document (INC-001–003).

- Performed **PostgreSQL performance troubleshooting** using EXPLAIN ANALYZE on a 100k-row dataset: sequential scan (~7 ms) → composite index → Bitmap Index Scan (~0.6 ms), with committed before/after evidence (PRB-001, CHG-001).

- Operated a **Docker Compose multi-service stack** (Nginx, Spring Boot, PostgreSQL, Prometheus, Grafana) with health checks, backup/restore scripts, and Nginx-vs-direct API triage for fault isolation.

- Added a **local Kubernetes extension** (kind) with Deployment/Service manifests, health probes, and safe `kubectl rollout undo` rollback — documented in runbooks without cloud deployment.

- Established **CI/CD validation gates** (GitHub Actions + local script): Java unit tests, Docker image build, Compose config check, and offline Kubernetes manifest schema validation (kubeconform).

- Produced **ITSM documentation** — SLA/priority matrix, escalation model, ServiceNow/Jira mappings, and a cross-linked artifact map covering incidents, problems, changes, and runbooks.

---

## Usage tips

- Lead with the bullet most relevant to the job posting (incident response vs. database vs. K8s).
- In interviews, walk one incident end-to-end (INC-001) and one permanent fix (PRB-001 → CHG-001).
- Describe it as a **local lab** or **portfolio project** — do not imply customer production experience.
