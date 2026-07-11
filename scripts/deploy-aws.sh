#!/bin/bash
set -e

echo "🚀 Deploying Bank of Anthos to AWS..."

# Configuration
AWS_REGION="ap-southeast-1"
CLUSTER_NAME="MuhsinNTU-bankofanthos"
NAMESPACE="bank-of-anthos"
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check prerequisites
command -v aws >/dev/null 2>&1 || { error "AWS CLI is required"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { error "kubectl is required"; exit 1; }
command -v helm >/dev/null 2>&1 || { error "helm is required"; exit 1; }
command -v docker >/dev/null 2>&1 || { error "docker is required"; exit 1; }

# Get AWS account ID if not set
if [ -z "$AWS_ACCOUNT_ID" ]; then
  AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
  ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
fi

# Step 1: Update kubeconfig
info "Updating kubeconfig..."
aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION

# Step 2: Install AWS Load Balancer Controller
info "Installing AWS Load Balancer Controller..."
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=v2.8.1" 2>/dev/null || true

helm repo add eks https://aws.github.io/eks-charts 2>/dev/null || true
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set image.tag=v2.8.1 \
  --set region=$AWS_REGION

# Step 3: Create namespaces
info "Creating namespaces..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Step 4: Deploy secrets
info "Deploying secrets..."
kubectl create secret generic jwt-key \
  --from-file=key.pem=extras/jwt/jwt-secret.yaml \
  -n $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic database-credentials \
  --from-literal=password='SecurePassword123!' \
  -n $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

# Step 5: Deploy application manifests
info "Deploying application..."
kubectl apply -f kubernetes-manifests/

# Step 6: Wait for deployments
info "Waiting for deployments to be ready..."
kubectl rollout status deployment/frontend -n $NAMESPACE --timeout=300s
kubectl rollout status deployment/userservice -n $NAMESPACE --timeout=300s
kubectl rollout status deployment/contacts -n $NAMESPACE --timeout=300s
kubectl rollout status deployment/balancereader -n $NAMESPACE --timeout=300s
kubectl rollout status deployment/ledgerwriter -n $NAMESPACE --timeout=300s
kubectl rollout status deployment/transactionhistory -n $NAMESPACE --timeout=300s

# Step 7: Deploy monitoring stack
info "Deploying monitoring stack (optional)..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --set grafana.adminPassword=GrafanaPassword123! \
  --set grafana.ingress.enabled=true \
  --set grafana.ingress.ingressClassName=alb \
  --set grafana.service.type=ClusterIP

echo ""
info "✅ Deployment completed successfully!"
echo ""
echo "=========================================="
echo " Application Resources:"
echo "=========================================="
kubectl get pods -n $NAMESPACE
echo ""
echo "=========================================="
echo " Services:"
echo "=========================================="
kubectl get svc -n $NAMESPACE
echo ""
echo "=========================================="
echo " Ingress:"
echo "=========================================="
kubectl get ingress -n $NAMESPACE 2>/dev/null || echo "No ingress resources found"