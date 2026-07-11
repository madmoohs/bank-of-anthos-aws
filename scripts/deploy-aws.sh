#!/bin/bash
set -e

echo "🚀 Deploying Bank of Anthos to AWS..."

# Configuration
AWS_REGION="ap-southeast-1"
CLUSTER_NAME="MuhsinNTU-bankofanthos"
NAMESPACE="bank-of-anthos"
ECR_REGISTRY="muhsinntu-bankofanthos"

# Update kubeconfig
echo "📝 Updating kubeconfig..."
aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION

# Install AWS Load Balancer Controller
echo "🔧 Installing AWS Load Balancer Controller..."
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=v2.8.1"

helm repo add eks https://aws.github.io/eks-charts
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set image.tag=v2.8.1 \
  --set region=$AWS_REGION

# Install External DNS
echo "🔧 Installing External DNS..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade --install external-dns bitnami/external-dns \
  -n external-dns --create-namespace \
  --set serviceAccount.create=true \
  --set serviceAccount.name=external-dns \
  --set provider=aws \
  --set domainFilters[0]=bankofanthos.example.com \
  --set awsZoneType=public \
  --set policy=sync \
  --set registry=txt \
  --set txtOwnerId=$CLUSTER_NAME

# Install Cluster Autoscaler
echo "🔧 Installing Cluster Autoscaler..."
helm repo add autoscaling https://kubernetes.github.io/autoscaler
helm upgrade --install cluster-autoscaler autoscaling/cluster-autoscaler \
  -n kube-system \
  --set autoDiscovery.clusterName=$CLUSTER_NAME \
  --set awsRegion=$AWS_REGION \
  --set serviceAccount.create=true \
  --set serviceAccount.name=cluster-autoscaler \
  --set rbac.create=true \
  --set podAnnotations."iam\.amazonaws\.com/role"=$CLUSTER_NAME-cluster-autoscaler

# Create namespaces
echo "📁 Creating namespaces..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Deploy secrets
echo "🔐 Deploying secrets..."
kubectl create secret generic jwt-key \
  --from-file=key.pem=extras/jwt/jwt-secret.yaml \
  -n $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic database-credentials \
  --from-literal=password='SecurePassword123!' \
  -n $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

# Deploy monitoring stack
echo "📊 Deploying monitoring stack..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --set grafana.adminPassword=GrafanaPassword123! \
  --set grafana.ingress.enabled=true \
  --set grafana.ingress.ingressClassName=alb \
  --set grafana.service.type=ClusterIP

# Build and push Docker images
echo "🐳 Building and pushing Docker images..."
SERVICES=("frontend" "userservice" "contacts" "accounts-db" "ledger-db" "balancereader" "ledgerwriter" "transactionhistory" "loadgenerator")

for service in "${SERVICES[@]}"; do
  echo "Building $service..."
  
  case $service in
    frontend)
      SERVICE_PATH="src/frontend"
      ;;
    userservice)
      SERVICE_PATH="src/accounts/userservice"
      ;;
    contacts)
      SERVICE_PATH="src/accounts/contacts"
      ;;
    accounts-db)
      SERVICE_PATH="src/accounts/accounts-db"
      ;;
    ledger-db)
      SERVICE_PATH="src/ledger/ledger-db"
      ;;
    balancereader)
      SERVICE_PATH="src/ledger/balancereader"
      ;;
    ledgerwriter)
      SERVICE_PATH="src/ledger/ledgerwriter"
      ;;
    transactionhistory)
      SERVICE_PATH="src/ledger/transactionhistory"
      ;;
    loadgenerator)
      SERVICE_PATH="src/loadgenerator"
      ;;
  esac
  
  aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
  
  docker build -t $ECR_REGISTRY/$service:latest $SERVICE_PATH
  docker push $ECR_REGISTRY/$service:latest
done

# Deploy application using Kubernetes manifests
echo "🚀 Deploying application..."
# For AWS deployment, we'll use the frontend service with LoadBalancer
kubectl apply -f deployments/applications/bank-of-anthos/frontend-aws.yaml -n $NAMESPACE

echo "✅ Deployment completed successfully!"
echo "🌐 Application URL: $(kubectl get svc frontend -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo "📊 Grafana URL: https://grafana.bankofanthos.example.com"