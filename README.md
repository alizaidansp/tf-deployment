# Terraform Infrastructure Deployments Guide
*Building robust cloud architecture  applications on AWS*

![Jenkins Pipeline Flow](demo_images/Terraform%20Infrastructure.png)
*This diagram illustrates the complete pipeline flow for the EC2 and EKS deployments, starting from code checkout, through Terraform stages, and ending with outputting the ALB DNS name.*


## Table of Contents
- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Deployment Options](#deployment-options)
  - [Laravel EC2 Deployment](#laravel-ec2-deployment)
    - [Directory Structure](#ec2-directory-structure)
    - [Deployment Steps](#ec2-deployment-steps)
    - [Jenkins Pipeline](#ec2-jenkins-pipeline)
    - [Cost Management](#ec2-cost-management)
  - [Laravel EKS Deployment](#laravel-eks-deployment)
    - [Directory Structure](#eks-directory-structure) 
    - [Deployment Steps](#eks-deployment-steps)
    - [Jenkins Pipeline](#eks-jenkins-pipeline)
    - [Cost Management](#eks-cost-management)
- [Architecture Comparison](#architecture-comparison)
- [Security Best Practices](#security-best-practices)
- [Scaling Considerations](#scaling-considerations)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Introduction

This guide presents two robust deployment architectures for Laravel applications on AWS: a traditional EC2-based setup and a modern Kubernetes solution using EKS. Both approaches use Infrastructure as Code (IAC) with Terraform to ensure consistency, repeatability, and maintainability across environments.

Whether you're building a personal project, a startup application, or an enterprise system, these deployment options will help you establish a production-ready environment with proper scaling, security, and operational efficiency.

## Prerequisites

Before diving into deployments, ensure you have the following tools and configurations ready:

- **AWS CLI**: Installed and configured with appropriate IAM credentials
  ```bash
  aws --version  # Should be 2.0+ for full EKS support
  ```

- **Terraform**: Version 1.5.0 or newer
  ```bash
  terraform --version
  ```

- **kubectl**: For Kubernetes deployments
  ```bash
  kubectl version --client
  ```

- **Jenkins**: Configured with the following plugins:
  - Git
  - Pipeline
  - AWS Credentials
  - Credentials Binding

- **Infracost**: (Optional) For infrastructure cost estimation
  ```bash
  infracost --version
  ```

## Deployment Options

### Laravel EC2 Deployment

The EC2 deployment architecture leverages traditional virtual machines combined with modern containerization. This approach uses an Application Load Balancer (ALB) for traffic distribution, EC2 instances within an Auto Scaling Group for running Docker-containerized Laravel applications, and an RDS database for persistent storage.

This architecture is ideal for teams familiar with traditional server management while still embracing some container benefits.

#### EC2 Directory Structure

```
laravel-ec2-deployment/
├── Jenkinsfile              # CI/CD pipeline definition
├── main.tf                  # Main Terraform configuration
├── modules/                 # Reusable Terraform modules
│   ├── alb/                 # Application Load Balancer configuration
│   ├── ec2/                 # EC2 instances with Auto Scaling Group
│   ├── iam/                 # IAM roles and policies
│   ├── rds/                 # RDS MySQL database
│   ├── security_group/      # Security groups for all components
│   └── vpc/                 # VPC, subnets, NAT Gateways, and routing
├── outputs.tf               # Terraform outputs (ALB DNS, EC2 IPs, etc.)
├── provider.tf              # AWS provider and S3 backend configuration
├── terraform.tfvars         # Variable values (stored securely in Jenkins)
└── variables.tf             # Variable declarations
```

**Key Scripts**
- `bash_scripts/state_file.sh`: Creates S3 bucket for Terraform state management
- `bash_scripts/cost_estimate.sh`: Estimates infrastructure costs using Infracost
- `bash_scripts/nuke.sh`: Emergency cleanup script for all resources

#### EC2 Deployment Steps

1. **Prepare Terraform State Storage**
   ```bash
   cd bash_scripts/
   ./state_file.sh
   ```
   This creates an encrypted S3 bucket with versioning and state locking enabled.

2. **Initialize Terraform**
   ```bash
   cd laravel-ec2-deployment/
   terraform init
   ```

3. **Review Planned Infrastructure**
   ```bash
   terraform plan
   ```
   Take time to understand the planned resources and their relationships.

4. **Deploy the Infrastructure**
   ```bash
   terraform apply
   ```
   This process typically takes 10-15 minutes as it creates VPC components, RDS instances, EC2 launch configurations, and more.

5. **Access Your Application**
   ```bash
   echo "Your application is available at: $(terraform output -raw alb_dns_name)"
   ```
   The ALB DNS name resolves to your load-balanced Laravel application.

#### EC2 Jenkins Pipeline

The included Jenkinsfile orchestrates end-to-end deployment with these stages:

![Jenkins Pipeline Flow](demo_images/ec2/checkout-code.png)
*Repository checkout stage showing successful code retrieval*

![Terraform Apply Stage](demo_images/ec2/tf-apply.png)
*Terraform apply stage showing resource provisioning*

The pipeline handles:
- Code checkout from Git
- Secure injection of Terraform variables
- S3 backend preparation
- Terraform initialization and validation
- Infrastructure deployment
- Output extraction

#### EC2 Cost Management

Monitor and optimize your infrastructure costs with the included Infracost integration:

![Cost Estimation Report](demo_images/ec2/cost-estimate.png)
*Monthly cost breakdown for EC2-based infrastructure*

```bash
# Generate detailed cost estimation
cd laravel-ec2-deployment/
terraform plan -out=tfplan
infracost breakdown --path=tfplan --format=json --out-file=infracost.json
../bash_scripts/cost_estimate.sh
```

### Laravel EKS Deployment

The EKS deployment offers a modern, container-orchestrated approach using Kubernetes. This solution provides enhanced scalability, improved resource utilization, and simplified application lifecycle management through Kubernetes' powerful orchestration capabilities.

This architecture is perfect for teams embracing microservices or requiring advanced deployment strategies like blue-green or canary deployments.

#### EKS Directory Structure

```
k8s_deployment/
├── Jenkinsfile              # CI/CD pipeline definition
├── main.tf                  # Main Terraform configuration for EKS
├── modules/                 # Reusable Terraform modules
│   ├── eks/                 # EKS cluster and node groups
│   ├── iam/                 # IAM roles for EKS
│   └── security_group/      # Security groups for EKS
├── k8s/                     # Kubernetes manifests
│   ├── deployment.yml       # Pod deployment configuration
│   └── services.yml         # LoadBalancer service configuration
├── outputs.tf               # Terraform outputs (cluster endpoint, etc.)
├── provider.tf              # AWS provider and S3 backend configuration
├── terraform.tfvars         # Variable values (stored securely)
└── variables.tf             # Variable declarations
```

**Key Scripts**
- `bash_scripts/deploy.sh`: Complete deployment script (alternative to Jenkins)
- `bash_scripts/state_file.sh`: S3 bucket creation for Terraform state
- `bash_scripts/cost_estimate.sh`: Infrastructure cost estimation

#### EKS Deployment Steps

1. **Prepare Terraform State Storage**
   ```bash
   cd bash_scripts/
   ./state_file.sh
   ```

2. **Initialize and Apply Terraform**
   ```bash
   cd k8s_deployment/
   terraform init
   terraform plan
   terraform apply
   ```
   This creates the EKS cluster, node groups, and necessary networking components.

3. **Configure kubectl**
   ```bash
   aws eks --region $(terraform output -raw aws_region) update-kubeconfig \
     --name $(terraform output -raw cluster_name)
   ```
   This updates your local kubectl configuration to connect to the new cluster.

4. **Deploy Kubernetes Resources**
   ```bash
   cd k8s/
   kubectl apply -f services.yml
   kubectl apply -f deployment.yml
   ```
   This deploys your application pods and creates a LoadBalancer service.

5. **Access Your Application**
   ```bash
   echo "Your application is available at: $(kubectl get svc nginx-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
   ```

#### EKS Jenkins Pipeline

The EKS Jenkins pipeline adds Kubernetes-specific stages to the deployment process:

![Kubectl Configuration](demo_images/eks/k8s-config.png)
*Kubectl configuration stage showing successful cluster connection*

![Kubernetes Resources Deployment](demo_images/eks/k8s-res.png)
*Kubernetes resources deployment showing successful pod creation*

The pipeline handles all infrastructure and application deployment steps:
- Infrastructure provisioning with Terraform
- Kubectl configuration
- Kubernetes manifest deployment
- Cluster information output

#### EKS Cost Management

EKS deployments have different cost considerations compared to EC2:

```bash
# Generate EKS cost estimation
cd k8s_deployment/
terraform plan -out=tfplan
infracost breakdown --path=tfplan --format=json --out-file=infracost.json
../bash_scripts/cost_estimate.sh
```

## Architecture Comparison

| Feature | EC2 Deployment | EKS Deployment |
|---------|----------------|----------------|
| **Scaling** | Auto Scaling Groups | Fixed ReplicaSet (e.g., 2 replicas) |
| **Resource Efficiency** | Good | Excellent |
| **Deployment Complexity** | Moderate | Higher |
| **Learning Curve** | Lower | Steeper |
| **Update Strategy** | Rolling updates | Multiple strategies available |
| **Typical Cost** | Moderate | Higher base cost, better optimization |
| **Best For** | Traditional applications | Microservices, complex deployments |

## Security Best Practices

Both deployment architectures implement security best practices:

- **Least Privilege IAM**: All IAM roles follow the principle of least privilege
- **Network Isolation**: Resources in private subnets with controlled access
- **Security Groups**: Granular control of network traffic
- **Secrets Management**: Sensitive data (like database credentials) managed securely
- **Encryption**: Data encryption at rest and in transit

## Scaling Considerations

**EC2 Deployment Scaling**
- Auto Scaling Groups respond to CPU/Memory thresholds
- ALB distributes traffic to healthy instances
- Scaling events create new instances from AMIs or launch templates

**EKS Deployment Scaling**
- **Static Replica Set**: The Kubernetes Deployment is configured with a fixed number of pods (e.g., `replicas: 2`) to ensure consistent application availability and load distribution.
- **Cluster Autoscaler**: Adjusts the number of EKS worker nodes based on pod placement needs, adding or removing nodes when resource demands change.
- **Manual Scaling**: Pod scaling requires updating the `replicas` field in the Deployment manifest and reapplying it, suitable for predictable workloads.


## Troubleshooting

**Common EC2 Deployment Issues**
- ALB health check failures: Check security groups and instance health
- Database connection issues: Verify RDS security group rules
- Auto Scaling problems: Review launch template and ASG configuration

**Common EKS Deployment Issues**
- Pod scheduling failures: Check node resources and taints
- Service connectivity issues: Verify network policies and security groups
- Authentication problems: Review AWS auth configuration map

## Contributing

Contributions to these deployment templates are welcome! Here's how you can contribute:

1. Fork the repository
2. Create a new branch for your feature or fix
3. Make changes and test thoroughly
4. Submit a pull request with clear description of improvements

Please follow these guidelines:
- Write clear commit messages
- Update documentation for any changes
- Add tests for new features
- Maintain consistent code style

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

