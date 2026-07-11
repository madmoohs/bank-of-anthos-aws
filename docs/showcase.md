# Bank of Anthos - AWS Deployment Showcase

## 🏦 Overview

Bank of Anthos is a sample banking application deployed on **Amazon Web Services (AWS)** with a complete **CI/CD pipeline**, **monitoring stack**, and **GitOps** workflow.

## 🎯 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      GitHub Repository                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐  │
│  │   CI Pipeline    │  │   CD Pipeline   │  │   Docs      │  │
│  │ (Build & Test)   │  │ (Deploy to EKS) │  │             │  │
│  └────────┬────────┘  └────────┬────────┘  └─────────────┘  │
└───────────┼────────────────────┼────────────────────────────┘
            │                    │
            ▼                    ▼
┌─────────────────────────────────────────────────────────────┐
│                      Amazon ECR                              │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────────┐ │
│  │front │ │users │ │contacts│ │balanc│ │ledger│ │transaction│ │
│  │ end  │ │ervice│ │       │ │reader│ │writer│ │history    │ │
│  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘ └──────────┘ │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    Amazon EKS Cluster                        │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              bank-of-anthos Namespace                │    │
│  │  ┌─────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐  │    │
│  │  │ Frontend│ │UserService│ │ Contacts │ │Balance │  │    │
│  │  │         │ │          │ │          │ │Reader  │  │    │
│  │  └─────────┘ └──────────┘ └──────────┘ └────────┘  │    │
│  │  ┌─────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐  │    │
│  │  │ Ledger  │ │Transaction│ │ Load     │ │Config  │  │    │
│  │  │ Writer  │ │ History   │ │ Generator│ │Maps    │  │    │
│  │  └─────────┘ └──────────┘ └──────────┘ └────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              monitoring Namespace                    │    │
│  │  ┌────────────┐  ┌────────────┐  ┌──────────────┐  │    │
│  │  │ Prometheus │  │  Grafana   │  │ Alertmanager │  │    │
│  │  └────────────┘  └────────────┘  └──────────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    AWS Services                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐   │
│  │   VPC    │ │   RDS    │ │   ALB    │ │   Route53    │   │
│  │  Network │ │PostgreSQL│ │  Ingress │ │     DNS      │   │
│  └──────────┘ └──────────┘ └──────────┘ └──────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Infrastructure (Terraform)

### Modules

| Module | Description | Status |
|--------|-------------|--------|
| **VPC** | Network with public/private subnets, NAT Gateway | ✅ |
| **IAM** | EKS cluster & node roles, OIDC provider | ✅ |
| **ECR** | Container registries for all services | ✅ |
| **EKS** | Kubernetes cluster with managed node groups | ✅ |
| **RDS** | PostgreSQL databases (accounts-db, ledger-db) | ✅ |
| **ALB** | Application Load Balancer for ingress | ✅ |
| **Route53** | DNS records for application & Grafana | ✅ |
| **Monitoring** | Prometheus/Grafana stack | ✅ |

### Terraform State

State is stored in **S3** with **DynamoDB** locking for team collaboration.

## 🔄 CI/CD Pipeline (GitHub Actions)

### CI Workflow (`.github/workflows/ci.yml`)

**Trigger:** Push/PR to `main` or `develop` branches

```
┌─────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│ Checkout│──▶│ Configure│──▶│  Login   │──▶│  Build & │
│  Code   │   │   AWS    │   │  to ECR  │   │   Push   │
└─────────┘   └──────────┘   └──────────┘   └──────────┘
                                                  │
                                                  ▼
                                            ┌──────────┐
                                            │  Lint &  │
                                            │ Validate │
                                            └──────────┘
```

**Services built:**
- frontend, userservice, contacts, accounts-db, ledger-db
- balancereader, ledgerwriter, transactionhistory, loadgenerator

### CD Workflow (`.github/workflows/cd.yml`)

**Trigger:** Push to `main` branch

```
┌─────────┐   ┌──────────┐   ┌──────────┐   ┌──────────────┐
│ Checkout│──▶│ Configure│──▶│  Update  │──▶│ Install AWS  │
│  Code   │   │   AWS    │   │kubeconfig│   │  LB Ctrl     │
└─────────┘   └──────────┘   └──────────┘   └──────────────┘
                                                    │
                                                    ▼
┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────────┐
│  Wait    │◀──│  Deploy  │◀──│  Create  │◀──│ Install      │
│  Ready   │   │   App    │   │ Secrets  │   │ Add-ons      │
└──────────┘   └──────────┘   └──────────┘   └──────────────┘
```

## 📊 Monitoring Stack

### Components

| Component | Purpose | Access |
|-----------|---------|--------|
| **Prometheus** | Metrics collection & storage | Internal |
| **Grafana** | Visualization & dashboards | `https://grafana.<domain>` |
| **Alertmanager** | Alert routing & management | Internal |

### Pre-configured Dashboards

- **Kubernetes Cluster** - Node/Pod metrics, resource usage
- **Application** - Request rates, latency, error rates
- **Database** - Connection pools, query performance
- **Load Balancer** - Traffic patterns, health checks

## 🗄️ Database Architecture

```
┌─────────────────────┐      ┌─────────────────────┐
│    accounts-db      │      │     ledger-db       │
│  (PostgreSQL RDS)   │      │  (PostgreSQL RDS)   │
├─────────────────────┤      ├─────────────────────┤
│ - User accounts     │      │ - Financial         │
│ - Contact info      │      │   transactions      │
│ - Authentication    │      │ - Account balances  │
└─────────────────────┘      └─────────────────────┘
        │                            │
        ▼                            ▼
┌─────────────────────┐      ┌─────────────────────┐
│   userservice       │      │  balancereader      │
│   contacts          │      │  ledgerwriter       │
│                     │      │  transactionhistory │
└─────────────────────┘      └─────────────────────┘
```

## 🔐 Security

- **IAM Roles for Service Accounts (IRSA)** - Pod-level IAM permissions
- **Secrets Management** - Kubernetes secrets for JWT keys & DB passwords
- **Network Security** - Security groups, private subnets for databases
- **Encryption** - EBS encryption, RDS encryption at rest
- **TLS** - HTTPS via ACM certificates on ALB

## 🚀 Quick Start

### Prerequisites

```bash
# Required tools
aws --version
terraform --version
kubectl version --client
helm version
docker --version
```

### Deploy Infrastructure

```bash
cd terraform/environments/aws

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy
terraform apply -auto-approve
```

### Deploy Application

```bash
# Option 1: Using deploy script
./scripts/deploy-aws.sh

# Option 2: Manual deployment
kubectl apply -f kubernetes-manifests/
```

### Access Application

```bash
# Get the ALB URL
kubectl get ingress -n bank-of-anthos

# Or get the frontend service URL
kubectl get svc frontend -n bank-of-anthos
```

## 🧪 Testing

```bash
# Check pod status
kubectl get pods -n bank-of-anthos

# Check logs
kubectl logs -f deployment/frontend -n bank-of-anthos

# Port forward for local access
kubectl port-forward svc/frontend -n bank-of-anthos 8080:80
```

## 📈 Performance

- **Auto-scaling** - Cluster Autoscaler for node scaling
- **Load Balancing** - ALB with health checks
- **Database** - RDS with automated backups
- **Monitoring** - Prometheus metrics with Grafana dashboards

## 🛠️ Troubleshooting

| Issue | Command |
|-------|---------|
| Pods not starting | `kubectl describe pod <name> -n bank-of-anthos` |
| ALB not provisioning | `kubectl describe ingress -n bank-of-anthos` |
| Database connection | `kubectl logs <pod> -n bank-of-anthos` |
| Monitoring issues | `kubectl get pods -n monitoring` |

## 🧹 Clean Up

```bash
# Destroy all infrastructure
cd terraform/environments/aws
terraform destroy -auto-approve
```

## 📚 Additional Resources

- [AWS Deployment Guide](./aws-deployment.md)
- [CI/CD Pipeline](./ci-cd-pipeline.md)
- [Monitoring Setup](./monitoring.md)
- [Terraform Configuration](./terraform.md)
- [Troubleshooting Guide](./troubleshooting.md)

---

## ✅ Deployment Checklist

- [x] Terraform infrastructure deployed
- [x] EKS cluster running
- [x] ECR repositories created
- [x] RDS databases provisioned
- [x] ALB configured
- [x] Route53 DNS records
- [x] Monitoring stack deployed
- [x] CI pipeline building images
- [x] CD pipeline deploying to EKS
- [x] Application accessible via ALB
- [x] Grafana dashboards available