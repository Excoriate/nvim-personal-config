#!/bin/bash
# Production-grade user data script for application instances
# Variables will be templated by Terraform

set -euo pipefail

# Configuration variables from Terraform
APPLICATION_NAME="${application_name}"
APPLICATION_PORT="${application_port}"
ENVIRONMENT="${environment}"
S3_BUCKET="${s3_bucket}"
AWS_REGION="${region}"

# Logging setup
LOG_FILE="/var/log/user-data.log"
exec > >(tee -a $LOG_FILE)
exec 2>&1

echo "=== Starting user data script at $(date) ==="
echo "Application: $APPLICATION_NAME"
echo "Environment: $ENVIRONMENT"
echo "Port: $APPLICATION_PORT"
echo "S3 Bucket: $S3_BUCKET"
echo "AWS Region: $AWS_REGION"

# Update system packages
echo "Updating system packages..."
yum update -y

# Install required packages
echo "Installing required packages..."
yum install -y \
    docker \
    awscli \
    cloudwatch-agent \
    amazon-ssm-agent \
    htop \
    curl \
    wget \
    git \
    unzip

# Configure and start Docker
echo "Configuring Docker..."
systemctl enable docker
systemctl start docker
usermod -a -G docker ec2-user

# Install Docker Compose
echo "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Configure CloudWatch agent
echo "Configuring CloudWatch agent..."
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "root"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/user-data.log",
                        "log_group_name": "/aws/ec2/$APPLICATION_NAME-$ENVIRONMENT",
                        "log_stream_name": "{instance_id}/user-data"
                    },
                    {
                        "file_path": "/var/log/application.log",
                        "log_group_name": "/aws/ec2/$APPLICATION_NAME-$ENVIRONMENT",
                        "log_stream_name": "{instance_id}/application"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "CWAgent",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "diskio": {
                "measurement": [
                    "io_time"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# Start CloudWatch agent
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

# Start SSM agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

echo "=== User data script completed at $(date) ==="
