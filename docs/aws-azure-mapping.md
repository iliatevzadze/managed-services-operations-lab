# AWS / Azure Mapping

## Purpose

Map local lab components to common managed services cloud equivalents — reflecting the hybrid context of enterprise Managed Services engagements.

## Component mapping

| Lab component | AWS equivalent | Azure equivalent | MS operations notes |
|---|---|---|---|
| spring-support-api (container) | ECS/Fargate or EKS Pod | AKS Pod or Container Apps | Check pod events, logs, resource limits |
| PostgreSQL | Amazon RDS PostgreSQL | Azure Database for PostgreSQL | Connection limits, failover, parameter groups |
| Nginx | ALB / NLB + target groups | Azure Application Gateway | Health probe config, backend pool status |
| Prometheus | Amazon Managed Prometheus | Azure Monitor managed Prometheus | Scrape targets, rule evaluation |
| Grafana | Amazon Managed Grafana | Azure Managed Grafana | Dashboards, data source health |
| Alertmanager | SNS + EventBridge routing | Action Groups + Logic Apps | Routing rules, on-call integration |
| Container orchestration | EKS | AKS | Rollback via deployment history |
| Secrets / config | Secrets Manager, SSM Parameter Store | Key Vault, App Configuration | Env var changes need change record |
| Backups | RDS automated backups, snapshots | Azure backup for PostgreSQL | RPO/RTO per contract |
| Logs | CloudWatch Logs | Log Analytics | Correlate app and infra timestamps |

## Operational command mapping

| Task | Local / K8s | AWS | Azure |
|---|---|---|---|
| Pod/container logs | `kubectl logs` / `docker compose logs` | CloudWatch Logs Insights | `az aks command` / Log Analytics |
| Restart workload | `kubectl rollout restart` | ECS force new deployment | AKS rollout restart |
| Database connectivity | `psql`, app health | RDS endpoint, security groups | Firewall rules, private endpoint |
| Rollback deployment | `kubectl rollout undo` | ECS task definition revision | `kubectl rollout undo` on AKS |
| Metrics | Prometheus UI | CloudWatch metrics / AMP | Azure Monitor metrics |

## Hybrid managed services context

Many Exxeta Managed Services customers run **hybrid** estates: on-premises integrations, cloud-hosted APIs, and centralized monitoring. This lab trains transferable skills:

- Same incident process regardless of cloud
- Runbook structure adapts; investigation logic stays consistent
- Escalation paths include cloud provider support for platform-layer issues

## Interview talking point

> "In the lab I troubleshoot via Docker Compose and kubectl. In production I'd map the same flow to RDS/AKS or Azure Database/AKS — checking health probes, connection pools, recent deployments, and metrics before touching config."

## Related documents

- [architecture-overview.md](architecture-overview.md)
- [local-setup-guide.md](local-setup-guide.md)
- [monitoring-guide.md](monitoring-guide.md)
