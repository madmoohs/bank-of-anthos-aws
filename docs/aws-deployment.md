# AWS Deployment Guide

This guide will help you deploy Bank of Anthos on AWS with EKS, RDS, ALB, and full CI/CD pipeline.

## Prerequisites

- AWS account with appropriate permissions
- Terraform >= 1.6
- kubectl
- Helm 3
- Docker
- AWS CLI configured with credentials
- GitHub repository with AWS secrets configured
- Domain name (e.g., bankofanthos.example.com)

## Architecture

The AWS deployment includes:
- **EKS Cluster** - Kubernetes cluster for running the application
- **ECR** - Container registry for storing Docker images
- **RDS** - Managed PostgreSQL databases (accounts-db and ledger-db)
- **ALB** - Application Load Balancer for ingress
- **Route53** - DNS management
- **Grafana/Prometheus** - Monitoring stack
- **GitHub Actions** - CI/CD pipeline

## Step 1: Configure Terraform

1. Update `terraform/environments/aws/terraform.tfvars` with your values:

```hcl
aws_region = "ap-southeast-1"

project_name = "your-project-name"
environment = "dev"
cluster_name = "your-cluster-name"

vpc_cidr = "10.0.0.0/16"

availability_zones = ["ap-southeast-1a", "ap-southeast-1b"]

public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

domain_name = "your-domain.com"
database_password = "YourSecurePassword123!"
grafana_admin_password = "YourGrafanaPassword123!"
grafana_hostname = "grafana.your-domain.com"
```

2. Update GitHub Actions secrets:
   - `AWS_ACCESS_KEY_ID` - Your AWS access key
   - `AWS_SECRET_ACCESS_KEY` - Your AWS secret key
   - `EXTERNAL_DNS_ROLE_ARN` - IAM role ARN for External DNS
   - `CLUSTER_AUTOSCALER_ROLE_ARN` - IAM role ARN for Cluster Autoscaler
   - `ECR_REGISTRY` - Your ECR registry URL (e.g., 123456789012.dkr.ecr.ap-southeast-1.amazonaws.com)

## Step 2: Deploy Infrastructure with Terraform

```bash
cd terraform/environments/aws

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy infrastructure
terraform apply
```

This will create:
- VPC with public and private subnets
- EKS cluster with node groups
- ECR repositories for all services
- RDS databases (accounts-db and ledger-db)
- ALB for ingress
- Route53 DNS records
- Monitoring stack (Prometheus/Grafana)
- IAM roles and service accounts

## Step 3: Configure kubectl

```bash
aws eks update-kubeconfig --name your-cluster-name --region ap-southeast-1
```

## Step 4: Deploy Kubernetes Add-ons

```bash
# Install AWS Load Balancer Controller
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=v2.8.1"

helm repo add eks https://aws.github.io/eks-charts
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=your-cluster-name \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set image.tag=v2.8.1 \
  --set region=ap-southeast-1

# Install External DNS
helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade --install external-dns bitnami/external-dns \
  -n external-dns --create-namespace \
  --set serviceAccount.create=true \
  --set serviceAccount.name=external-dns \
  --set provider=aws \
  --set domainFilters[0]=your-domain.com \
  --set awsZoneType=public

# Install Cluster Autoscaler
helm repo add autoscaling https://kubernetes.github.io/autoscaler
helm upgrade --install cluster-autoscaler autoscaling/cluster-autoscaler \
  -n kube-system \
  --set autoDiscovery.clusterName=your-cluster-name \
  --set awsRegion=ap-southeast-1 \
  --set serviceAccount.create=true \
  --set serviceAccount.name=cluster-autoscaler \
  --set podAnnotations."iam\.amazonaws\.com/role"=your-cluster-name-cluster-autoscaler
```

## Step 5: Configure DNS

1. Create a TLS certificate in AWS Certificate Manager (ACM) for your domain
2. Update `terraform/environments/aws/main.tf` to pass the certificate ARN to the EKS module
3. Update Route53 nameservers at your domain registrar to point to AWS Route53

## Step 6: Deploy the Application

### Option A: Manual Deployment

```bash
# Make the deploy script executable
chmod +x scripts/deploy-aws.sh

# Run the deployment script
./scripts/deploy-aws.sh
```

### Option B: GitHub Actions CI/CD

The repository includes two GitHub Actions workflows:

1. **CI Workflow** (`.github/workflows/ci.yml`) - Builds and pushes Docker images to ECR on every PR/push
2. **CD Workflow** (`.github/workflows/cd.yml`) - Deploys to EKS on push to main branch

The CD workflow will:
- Update kubeconfig
- Install required Kubernetes add-ons
- Create namespaces and secrets
- Deploy the application
- Wait for deployments to be ready

## Step 7: Access the Application

After deployment, you can access:

- **Application**: http://your-domain.com (or the ALB DNS name)
- **Grafana Dashboard**: https://grafana.your-domain.com
  - Username: admin
  - Password: (from terraform.tfvars)

## Monitoring

The monitoring stack includes:
- **Prometheus** - Metrics collection and storage
- **Grafana** - Visualization and dashboards
- **Alertmanager** - Alert routing and management

Access Grafana dashboards to monitor:
- Cluster resource utilization
- Application performance metrics
- Database metrics
- Load balancer metrics

## Database Access

To connect to RDS databases:

```bash
# Get the database endpoint
terraform output accounts_db_endpoint
terraform output ledger_db_endpoint

# Port forward for local access
kubectl port-forward svc/postgres -n bank-of-anthos 5432:5432

# Connect using psql
psql -h <db-endpoint> -U postgres -d accounts-db
```

## Troubleshooting

### Pods not starting
```bash
kubectl get pods -n bank-of-anthos
kubectl describe pod <pod-name> -n bank-of-anthos
kubectl logs <pod-name> -n bank-of-anthos
```

### ALB not provisioning
```bash
kubectl get ingress -n bank-of-anthos
kubectl describe ingress frontend -n bank-of-anthos
kubectl get events -n bank-of-anthos --sort-by='.lastTimestamp'
```

### External DNS not working
```bash
kubectl get pods -n external-dns
kubectl logs -l app=external-dns -n external-dns
```

## Clean Up

To destroy all resources:

```bash
cd terraform/environments/aws
terraform destroy
```

## Cost Optimization

- Use spot instances for non-critical workloads
- Enable RDS storage auto-scaling
- Set up CloudWatch alarms for cost monitoring
- Use ECR lifecycle policies to clean up old images
- Schedule non-production resources to shut down during off-hours

## Security Best Practices

1. Enable RDS encryption at rest
2. Enable EKS cluster encryption
3. Use IAM roles for service accounts (IRSA)
4. Enable AWS Secrets Manager for sensitive data
5. Enable VPC flow logs
6. Use security groups to restrict access
7. Enable CloudTrail for audit logging
8. Regular security patches and updates

## Next Steps

- Set up AWS WAF for the ALB
- Configure AWS Backup for RDS
- Set up CloudWatch alarms and notifications
- Implement AWS X-Ray for distributed tracing
- Configure AWS GuardDuty for threat detection
- Set up AWS Config for compliance monitoring