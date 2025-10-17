#!/bin/bash  
set -e  
  
# Configurable variables with defaults  
K8S_VERSION="${K8S_VERSION:-v1.32}"  
K8S_REPO_BASE="https://pkgs.k8s.io/core:/stable:/$K8S_VERSION/rpm/"  
K8S_REPO_KEY="$K8S_REPO_BASE/repodata/repomd.xml.key"  
CLUSTER_NAME="${CLUSTER_NAME:-mongodb}"  
NAMESPACE="${NAMESPACE:-mongodb}"  
MONGODB_OPERATOR_VERSION="${MONGODB_OPERATOR_VERSION:-1.3.0}"  
PORT_MAPPING="${PORT_MAPPING:-30010:30010@loadbalancer}"  
USER="${USER:-ec2-user}"  
  
LOG_FILE="/tmp/startup.log"  
  
log() {  
  echo "$@" | tee -a "$LOG_FILE"  
}  
  
log "Running as $(whoami)"  
  
log "Installing Docker..."  
sudo yum install -y docker  
  
log "Adding Kubernetes repo for $K8S_VERSION..."  
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo  
[kubernetes]
name=Kubernetes
baseurl=${K8S_REPO_BASE}
enabled=1
gpgcheck=1
gpgkey=${K8S_REPO_KEY}
EOF
 
log "Installing kubectl..."  
sudo yum install -y kubectl  
  
log "Starting and enabling Docker..."  
sudo systemctl start docker  
sudo systemctl enable docker  
  
log "Adding $USER to docker group..."  
sudo usermod -aG docker "$USER"  
log "User info: $(id $USER)"  
  
log "Installing k3d..."  
sudo -u "$USER" bash -c "curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash"  
  
log "Creating k3d cluster '$CLUSTER_NAME'..."  
sudo -u "$USER" k3d cluster create "$CLUSTER_NAME"  
  
log "Creating namespace '$NAMESPACE'..."  
sudo -u "$USER" kubectl create ns "$NAMESPACE"  
  
log "Applying MongoDB Operator $MONGODB_OPERATOR_VERSION..."  
sudo -u "$USER" kubectl apply -f "https://raw.githubusercontent.com/mongodb/mongodb-kubernetes/$MONGODB_OPERATOR_VERSION/public/mongodb-kubernetes.yaml"  
sudo -u "$USER" kubectl apply -f "https://raw.githubusercontent.com/mongodb/mongodb-kubernetes/$MONGODB_OPERATOR_VERSION/public/crds.yaml"  
  
log "Editing k3d cluster '$CLUSTER_NAME', adding port $PORT_MAPPING..."  
sudo -u "$USER" k3d cluster edit "$CLUSTER_NAME" --port-add "$PORT_MAPPING"

log "Waiting 10 seconds before setting namespace context..."  
sleep 10  
  
log "Switching kubectl namespace for current context..."  
sudo -u "$USER" kubectl config set-context "$(sudo -u "$USER" kubectl config current-context)" --namespace="$NAMESPACE"    
  
log "K8s Startup script completed successfully!"  

