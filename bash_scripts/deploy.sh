#!/bin/bash
# Full Deployment Script for EKS + Kubernetes Resources
# Usage: ./deploy.sh [environment]

set -e  # Exit on error

# Configuration
ENVIRONMENT=${1:-dev}
TIMESTAMP=$(date +%Y%m%d%H%M%S)
TF_DIR=$(pwd)
K8S_DIR="${TF_DIR}/k8s"
LOG_DIR="${TF_DIR}/logs"
mkdir -p "${LOG_DIR}"

# Initialize logging
exec > >(tee -a "${LOG_DIR}/deployment-${TIMESTAMP}.log") 2>&1

echo "🚀 Starting deployment for environment: ${ENVIRONMENT}"
echo "📌 Timestamp: ${TIMESTAMP}"
echo "----------------------------------------"

terraform_init() {
    echo "🔧 Initializing Terraform..."
    terraform init
}

validate_infra() {
    echo "🔍 Validating Terraform configuration..."
    terraform validate
}

plan_infra() {
    echo "📝 Generating infrastructure plan..."
    terraform plan -out=tfplan.${TIMESTAMP}
}

apply_infra() {
    echo "🛠 Applying infrastructure changes..."
    terraform apply -auto-approve tfplan.${TIMESTAMP}
}

configure_kubectl() {
    echo "⚙ Configuring kubectl context..."
    aws eks --region $(terraform output -raw aws_region) update-kubeconfig \
        --name $(terraform output -raw cluster_name)
}

deploy_k8s() {
    echo "🚢 Deploying Kubernetes resources..."
    cd "${K8S_DIR}"
    
    # Retrieve RDS endpoint
    # RDS_ENDPOINT=$(terraform output -raw db_endpoint)
    # RDS_ENDPOINT=$(terraform output -raw db_endpoint | cut -d':' -f1 | sed 's/%$//')
    
    # Replace the placeholder in the config map file with the actual RDS endpoint
    # sed "s|\${DB_HOST}|${RDS_ENDPOINT}|g" laravel-config.yml > laravel-config-temp.yml
    
    
    declare -a MANIFESTS=(
        # "secrets.yml"
        "laravel-config.yml"  # Use the temporary file with replaced RDS endpoint
        "services.yml"
        "deployment.yml"
        # "ingress.yml"
        "migration-job.yml"
    )
    
    for manifest in "${MANIFESTS[@]}"; do
        echo "📄 Applying ${manifest}..."
        kubectl apply -f "${manifest}"
    done
    
    # Clean up the temporary file
    # rm laravel-config-temp.yml
    
    cd "${TF_DIR}"
}

# verify_deployment() {
#     echo "✅ Verifying deployment..."
    
#     echo "🖥 Kubernetes Nodes:"
#     kubectl get nodes -o wide
    
#     echo "📦 Kubernetes Pods:"
#     kubectl get pods -w --request-timeout=5s
    
#     echo "🔌 Services:"
#     kubectl get svc
    
#     echo "🌐 Ingress:"
#     kubectl get ingress
    
#     ALB_DNS=$(terraform output -raw alb_dns_name)
#     echo "📡 Testing ALB endpoint: ${ALB_DNS}"
#     curl -I --retry 3 --retry-delay 5 "${ALB_DNS}"
    
#     RDS_ENDPOINT=$(terraform output -raw db_endpoint)
#     echo "🛢 RDS Endpoint: ${RDS_ENDPOINT}"
# }

show_credentials() {
    echo "🔐 Deployment Credentials:"
    echo "--------------------------"
    echo "EKS Cluster Name: $(terraform output -raw cluster_name)"
    # echo "Kubernetes API Endpoint: $(terraform output -raw cluster_endpoint)"
    # echo "ALB DNS Name: $(terraform output -raw alb_dns_name)"
    echo "RDS Endpoint: $(terraform output -raw db_endpoint)"

}

# Main execution flow
main() {
    terraform_init
    validate_infra
    plan_infra
    apply_infra
    configure_kubectl
    deploy_k8s
    sleep 15  # Wait for resources to initialize
    # verify_deployment
    show_credentials
    
    echo "🎉 Deployment completed successfully!"
    echo "🕒 Total time: $(($(date +%s) - ${TIMESTAMP})) seconds"
}

# Run main function
time main


# Make executable
# chmod +x deploy.sh


# cd into k8s_deployment and run

# ~/all-dev/PHASE-2/AWS/Terraform/lloyd_assignment/bash_scripts/deploy.sh && tail -f logs/deployment-*.log
# modify migration-job(DB_HOST) and laravel-config(DB_HOST)

# kubectl delete all,configmap,secret,pvc,ingress --all -n default
