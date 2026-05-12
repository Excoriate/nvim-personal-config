# Production-grade Terraform variables file
# Test configuration for LSP functionality

environment = "development"
aws_region  = "us-west-2"

vpc_config = {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  availability_zones   = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = false
  
  # Optional features
  enable_vpn_gateway  = false
  enable_flow_logs    = true
  flow_logs_retention = 14
}

application_config = {
  name    = "my-web-app"
  version = "1.2.3"
  port    = 8080
  
  health_check = {
    enabled             = true
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
  
  scaling = {
    min_capacity = 2
    max_capacity = 10
    target_cpu   = 70
  }
  
  # Feature flags for testing
  features = {
    enable_monitoring = true
    enable_backups   = true
    enable_ssl       = true
    debug_mode      = false
  }
}

# Additional tags for resource management
tags = {
  Owner       = "DevOps Team"
  Project     = "Web Application"
  Repository  = "my-web-app-infra"
  Contact     = "devops@example.com"
}
