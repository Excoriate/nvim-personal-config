# Production-Grade Terraform Configuration Test File
# Tests: Advanced HCL syntax, modules, data sources, locals, and enterprise patterns

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
  }
  
  # Backend configuration for production state management
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "infrastructure/production/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    
    # Additional backend configuration for production safety
    versioning = true
    
    assume_role {
      role_arn = "arn:aws:iam::ACCOUNT_ID:role/TerraformExecutionRole"
    }
  }
}

# Provider configuration with advanced features
provider "aws" {
  region = var.aws_region
  
  # Production-grade provider configuration
  default_tags {
    tags = local.common_tags
  }
  
  # Assume role for cross-account access
  assume_role {
    role_arn     = var.execution_role_arn
    session_name = "TerraformExecution-${local.timestamp}"
  }
  
  # Retry configuration for better reliability
  retry_mode      = "adaptive"
  max_retries     = 3
  
  # Custom endpoints for private AWS setups
  dynamic "endpoints" {
    for_each = var.custom_endpoints != null ? [1] : []
    content {
      s3  = var.custom_endpoints.s3
      ec2 = var.custom_endpoints.ec2
      rds = var.custom_endpoints.rds
    }
  }
}

# Advanced variable definitions with validation
variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  
  validation {
    condition = contains([
      "development",
      "staging", 
      "production"
    ], var.environment)
    error_message = "Environment must be one of: development, staging, production."
  }
}

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-west-2"
  
  validation {
    condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.aws_region))
    error_message = "AWS region must be in the format: us-west-2."
  }
}

variable "vpc_config" {
  description = "VPC configuration object"
  type = object({
    cidr_block           = string
    enable_dns_hostnames = bool
    enable_dns_support   = bool
    availability_zones   = list(string)
    private_subnets      = list(string)
    public_subnets       = list(string)
    enable_nat_gateway   = bool
    single_nat_gateway   = bool
    
    # Advanced VPC features
    enable_vpn_gateway   = optional(bool, false)
    enable_flow_logs     = optional(bool, true)
    flow_logs_retention  = optional(number, 30)
  })
  
  validation {
    condition = can(cidrhost(var.vpc_config.cidr_block, 0))
    error_message = "VPC CIDR block must be a valid IPv4 CIDR."
  }
  
  validation {
    condition = length(var.vpc_config.availability_zones) >= 2
    error_message = "At least 2 availability zones must be specified for high availability."
  }
}

variable "application_config" {
  description = "Application-specific configuration"
  type = object({
    name         = string
    version      = string
    port         = number
    health_check = object({
      enabled             = bool
      path                = string
      interval            = number
      timeout             = number
      healthy_threshold   = number
      unhealthy_threshold = number
    })
    scaling = object({
      min_capacity = number
      max_capacity = number
      target_cpu   = number
    })
    
    # Feature flags
    features = optional(map(bool), {})
  })
  
  validation {
    condition     = var.application_config.port > 0 && var.application_config.port < 65536
    error_message = "Application port must be between 1 and 65535."
  }
  
  validation {
    condition = (
      var.application_config.scaling.min_capacity <= var.application_config.scaling.max_capacity &&
      var.application_config.scaling.min_capacity > 0
    )
    error_message = "Min capacity must be positive and less than or equal to max capacity."
  }
}

variable "execution_role_arn" {
  description = "ARN of the IAM role for Terraform execution"
  type        = string
  default     = null
  
  validation {
    condition = var.execution_role_arn == null || can(regex(
      "^arn:aws:iam::[0-9]{12}:role/[a-zA-Z0-9+=,.@_-]+$",
      var.execution_role_arn
    ))
    error_message = "Execution role ARN must be a valid IAM role ARN."
  }
}

variable "custom_endpoints" {
  description = "Custom AWS service endpoints for private deployments"
  type = object({
    s3  = optional(string)
    ec2 = optional(string)
    rds = optional(string)
  })
  default = null
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
  
  validation {
    condition = alltrue([
      for key, value in var.tags : 
      can(regex("^[a-zA-Z0-9+=._:/-]*$", key)) && 
      can(regex("^[a-zA-Z0-9+=._:/@-]*$", value))
    ])
    error_message = "Tag keys and values must contain only valid characters."
  }
}

# Complex local values with advanced HCL functions
locals {
  timestamp = formatdate("YYYY-MM-DD-hhmm", timestamp())
  
  # Common tags applied to all resources
  common_tags = merge(
    {
      Environment        = var.environment
      ManagedBy         = "Terraform"
      Project           = var.application_config.name
      Version           = var.application_config.version
      CreatedAt         = local.timestamp
      BusinessUnit      = "Engineering"
      CostCenter        = "Infrastructure"
      DataClassification = var.environment == "production" ? "Confidential" : "Internal"
    },
    var.tags
  )
  
  # Network configuration calculations
  az_count = length(var.vpc_config.availability_zones)
  
  # Calculate subnet configurations
  private_subnet_configs = {
    for idx, subnet_cidr in var.vpc_config.private_subnets : 
    "private-${idx + 1}" => {
      cidr_block        = subnet_cidr
      availability_zone = var.vpc_config.availability_zones[idx % local.az_count]
      type              = "private"
    }
  }
  
  public_subnet_configs = {
    for idx, subnet_cidr in var.vpc_config.public_subnets : 
    "public-${idx + 1}" => {
      cidr_block        = subnet_cidr
      availability_zone = var.vpc_config.availability_zones[idx % local.az_count]
      type              = "public"
    }
  }
  
  all_subnet_configs = merge(local.private_subnet_configs, local.public_subnet_configs)
  
  # Security group rule definitions
  ingress_rules = [
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Application Port"
      from_port   = var.application_config.port
      to_port     = var.application_config.port
      protocol    = "tcp"
      cidr_blocks = [var.vpc_config.cidr_block]
    }
  ]
  
  # Conditional logic for environment-specific configurations
  is_production = var.environment == "production"
  
  backup_retention_days = local.is_production ? 30 : 7
  enable_monitoring     = local.is_production ? true : false
  instance_type        = local.is_production ? "t3.large" : "t3.medium"
  
  # Generate unique names with proper formatting
  name_prefix = "${var.application_config.name}-${var.environment}"
  
  # Feature flag processing
  enabled_features = {
    for feature, enabled in var.application_config.features :
    feature => enabled
  }
}

# Data sources for existing AWS resources
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
  
  filter {
    name   = "region-name"
    values = [data.aws_region.current.name]
  }
}

# Advanced data source with complex filtering
data "aws_ami" "application_ami" {
  most_recent = true
  owners      = ["amazon", "self"]
  
  filter {
    name = "name"
    values = [
      "amzn2-ami-hvm-*-x86_64-gp2",
      "${var.application_config.name}-*"
    ]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name   = "state"
    values = ["available"]
  }
  
  # Use custom AMI if available, fallback to Amazon Linux 2
  name_regex = var.environment == "production" ? 
    "${var.application_config.name}-prod-.*" : 
    "amzn2-ami-hvm-.*"
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "application_policy" {
  # CloudWatch Logs permissions
  statement {
    sid = "CloudWatchLogs"
    
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/ec2/${local.name_prefix}*"
    ]
    
    effect = "Allow"
  }
  
  # S3 permissions for application data
  statement {
    sid = "S3Access"
    
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    
    resources = [
      "${aws_s3_bucket.application_data.arn}/*"
    ]
    
    effect = "Allow"
  }
  
  # Conditional permissions based on environment
  dynamic "statement" {
    for_each = local.is_production ? [1] : []
    
    content {
      sid = "ProductionOnlyPermissions"
      
      actions = [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath"
      ]
      
      resources = [
        "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${local.name_prefix}/*"
      ]
      
      effect = "Allow"
    }
  }
}

# Random resources for unique naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
  
  keepers = {
    environment = var.environment
    application = var.application_config.name
  }
}

resource "random_password" "database_password" {
  count = local.is_production ? 1 : 0
  
  length  = 32
  special = true
  
  keepers = {
    environment = var.environment
    version     = var.application_config.version
  }
}

# TLS private key for secure communication
resource "tls_private_key" "application_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "tls_self_signed_cert" "application_cert" {
  private_key_pem = tls_private_key.application_key.private_key_pem
  
  subject {
    common_name  = "${local.name_prefix}.internal"
    organization = "My Organization"
  }
  
  validity_period_hours = 8760 # 1 year
  
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth"
  ]
  
  lifecycle {
    create_before_destroy = true
  }
}

# VPC and networking resources with advanced configuration
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_config.cidr_block
  enable_dns_hostnames = var.vpc_config.enable_dns_hostnames
  enable_dns_support   = var.vpc_config.enable_dns_support
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-vpc"
      Type = "Main VPC"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# Internet Gateway with conditional creation
resource "aws_internet_gateway" "main" {
  count = length(var.vpc_config.public_subnets) > 0 ? 1 : 0
  
  vpc_id = aws_vpc.main.id
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-igw"
      Type = "Internet Gateway"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# Subnets with dynamic configuration
resource "aws_subnet" "subnets" {
  for_each = local.all_subnet_configs
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  
  # Enable public IP assignment for public subnets
  map_public_ip_on_launch = each.value.type == "public"
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-subnet-${each.key}"
      Type = title(each.value.type)
      AZ   = each.value.availability_zone
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = var.vpc_config.enable_nat_gateway ? (
    var.vpc_config.single_nat_gateway ? 1 : length(var.vpc_config.public_subnets)
  ) : 0
  
  domain = "vpc"
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-eip-nat-${count.index + 1}"
      Type = "NAT Gateway EIP"
    }
  )
  
  depends_on = [aws_internet_gateway.main]
  
  lifecycle {
    create_before_destroy = true
  }
}

# NAT Gateways for private subnet internet access
resource "aws_nat_gateway" "main" {
  count = var.vpc_config.enable_nat_gateway ? (
    var.vpc_config.single_nat_gateway ? 1 : length(var.vpc_config.public_subnets)
  ) : 0
  
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.subnets[
    "public-${count.index + 1}"
  ].id
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-nat-${count.index + 1}"
      Type = "NAT Gateway"
    }
  )
  
  depends_on = [aws_internet_gateway.main]
  
  lifecycle {
    create_before_destroy = true
  }
}

# Route tables with complex routing logic
resource "aws_route_table" "public" {
  count = length(var.vpc_config.public_subnets) > 0 ? 1 : 0
  
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-rt-public"
      Type = "Public Route Table"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "private" {
  count = length(var.vpc_config.private_subnets)
  
  vpc_id = aws_vpc.main.id
  
  # Route to NAT Gateway if enabled
  dynamic "route" {
    for_each = var.vpc_config.enable_nat_gateway ? [1] : []
    
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[
        var.vpc_config.single_nat_gateway ? 0 : count.index
      ].id
    }
  }
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-rt-private-${count.index + 1}"
      Type = "Private Route Table"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# Route table associations with advanced logic
resource "aws_route_table_association" "public" {
  for_each = {
    for k, v in local.public_subnet_configs : k => v
    if length(var.vpc_config.public_subnets) > 0
  }
  
  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.public[0].id
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table_association" "private" {
  for_each = {
    for k, v in local.private_subnet_configs : k => v
  }
  
  subnet_id = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.private[
    tonumber(split("-", each.key)[1]) - 1
  ].id
  
  lifecycle {
    create_before_destroy = true
  }
}

# Security groups with dynamic rules
resource "aws_security_group" "application" {
  name_prefix = "${local.name_prefix}-app-"
  description = "Security group for ${var.application_config.name} application"
  vpc_id      = aws_vpc.main.id
  
  # Dynamic ingress rules
  dynamic "ingress" {
    for_each = local.ingress_rules
    
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  
  # Conditional SSH access for non-production environments
  dynamic "ingress" {
    for_each = !local.is_production ? [1] : []
    
    content {
      description = "SSH access for development"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.vpc_config.cidr_block]
    }
  }
  
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-sg-application"
      Type = "Application Security Group"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# Application Load Balancer with advanced configuration
resource "aws_lb" "application" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.application.id]
  
  subnets = [
    for subnet_key, subnet_config in local.public_subnet_configs :
    aws_subnet.subnets[subnet_key].id
  ]
  
  enable_deletion_protection       = local.is_production
  enable_cross_zone_load_balancing = true
  enable_http2                     = true
  enable_waf_fail_open            = false
  
  # Access logs configuration
  access_logs {
    bucket  = aws_s3_bucket.access_logs.bucket
    prefix  = "alb-access-logs"
    enabled = true
  }
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-alb"
      Type = "Application Load Balancer"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# Target group with health check configuration
resource "aws_lb_target_group" "application" {
  name     = "${local.name_prefix}-tg"
  port     = var.application_config.port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  
  health_check {
    enabled             = var.application_config.health_check.enabled
    healthy_threshold   = var.application_config.health_check.healthy_threshold
    unhealthy_threshold = var.application_config.health_check.unhealthy_threshold
    timeout             = var.application_config.health_check.timeout
    interval            = var.application_config.health_check.interval
    path                = var.application_config.health_check.path
    matcher             = "200,302"
    protocol            = "HTTP"
  }
  
  # Stickiness configuration for session affinity
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = local.is_production
  }
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-tg"
      Type = "Target Group"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# IAM resources with comprehensive policies
resource "aws_iam_role" "instance_role" {
  name_prefix        = "${local.name_prefix}-instance-"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-instance-role"
      Type = "EC2 Instance Role"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy" "application_policy" {
  name_prefix = "${local.name_prefix}-app-policy-"
  description = "Policy for ${var.application_config.name} application"
  policy      = data.aws_iam_policy_document.application_policy.json
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-app-policy"
      Type = "Application Policy"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "application_policy" {
  role       = aws_iam_role.instance_role.name
  policy_arn = aws_iam_policy.application_policy.arn
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "application" {
  name_prefix = "${local.name_prefix}-profile-"
  role        = aws_iam_role.instance_role.name
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-instance-profile"
      Type = "Instance Profile"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# S3 buckets with advanced configuration
resource "aws_s3_bucket" "application_data" {
  bucket        = "${local.name_prefix}-app-data-${random_id.bucket_suffix.hex}"
  force_destroy = !local.is_production
  
  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-app-data"
      Type        = "Application Data Bucket"
      ContentType = "ApplicationData"
    }
  )
  
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "access_logs" {
  bucket        = "${local.name_prefix}-access-logs-${random_id.bucket_suffix.hex}"
  force_destroy = !local.is_production
  
  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-access-logs"
      Type        = "Access Logs Bucket"
      ContentType = "Logs"
    }
  )
  
  lifecycle {
    prevent_destroy = true
  }
}

# S3 bucket configurations
resource "aws_s3_bucket_versioning" "application_data" {
  bucket = aws_s3_bucket.application_data.id
  
  versioning_configuration {
    status = local.is_production ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "application_data" {
  bucket = aws_s3_bucket.application_data.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "application_data" {
  bucket = aws_s3_bucket.application_data.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Launch template with user data and advanced features
resource "aws_launch_template" "application" {
  name_prefix   = "${local.name_prefix}-lt-"
  image_id      = data.aws_ami.application_ami.id
  instance_type = local.instance_type
  key_name      = var.environment != "production" ? aws_key_pair.development[0].key_name : null
  
  vpc_security_group_ids = [aws_security_group.application.id]
  
  iam_instance_profile {
    name = aws_iam_instance_profile.application.name
  }
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    application_name = var.application_config.name
    application_port = var.application_config.port
    environment      = var.environment
    s3_bucket        = aws_s3_bucket.application_data.bucket
    region           = data.aws_region.current.name
  }))
  
  # Instance metadata service configuration
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  
  # EBS optimization
  ebs_optimized = true
  
  # Block device mappings
  block_device_mappings {
    device_name = "/dev/xvda"
    
    ebs {
      volume_type           = "gp3"
      volume_size           = 20
      iops                 = 3000
      throughput           = 125
      encrypted            = true
      delete_on_termination = true
    }
  }
  
  # Network interface configuration
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups            = [aws_security_group.application.id]
  }
  
  tag_specifications {
    resource_type = "instance"
    
    tags = merge(
      local.common_tags,
      {
        Name = "${local.name_prefix}-instance"
        Type = "Application Instance"
      }
    )
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group with comprehensive configuration
resource "aws_autoscaling_group" "application" {
  name                = "${local.name_prefix}-asg"
  vpc_zone_identifier = [
    for subnet_key, subnet_config in local.private_subnet_configs :
    aws_subnet.subnets[subnet_key].id
  ]
  
  target_group_arns   = [aws_lb_target_group.application.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300
  
  min_size         = var.application_config.scaling.min_capacity
  max_size         = var.application_config.scaling.max_capacity
  desired_capacity = var.application_config.scaling.min_capacity
  
  # Launch template configuration
  launch_template {
    id      = aws_launch_template.application.id
    version = "$Latest"
  }
  
  # Instance refresh configuration for rolling updates
  instance_refresh {
    strategy = "Rolling"
    
    preferences {
      min_healthy_percentage = 50
      instance_warmup       = 300
    }
    
    triggers = ["tag"]
  }
  
  # Lifecycle hooks for graceful shutdown
  initial_lifecycle_hook {
    name                 = "instance-launching"
    default_result       = "ABANDON"
    heartbeat_timeout    = 300
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
  }
  
  initial_lifecycle_hook {
    name                 = "instance-terminating"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 300
    lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
  }
  
  # Tags that propagate to instances
  dynamic "tag" {
    for_each = merge(
      local.common_tags,
      {
        Name = "${local.name_prefix}-asg-instance"
        Type = "Auto Scaling Group Instance"
      }
    )
    
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  
  lifecycle {
    create_before_destroy = true
    ignore_changes       = [desired_capacity]
  }
}

# Auto Scaling Policies with CloudWatch integration
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${local.name_prefix}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.application.name
  
  policy_type = "SimpleScaling"
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${local.name_prefix}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.application.name
  
  policy_type = "SimpleScaling"
}

# CloudWatch alarms for auto scaling
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${local.name_prefix}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.application_config.scaling.target_cpu
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.application.name
  }
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-cpu-high-alarm"
      Type = "CloudWatch Alarm"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${local.name_prefix}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.application_config.scaling.target_cpu - 20
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.application.name
  }
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-cpu-low-alarm"
      Type = "CloudWatch Alarm"
    }
  )
}

# Key pair for development environments
resource "aws_key_pair" "development" {
  count = var.environment != "production" ? 1 : 0
  
  key_name   = "${local.name_prefix}-dev-key"
  public_key = tls_private_key.application_key.public_key_openssh
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-dev-key"
      Type = "Development Key Pair"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# Local file resource for private key (development only)
resource "local_file" "private_key" {
  count = var.environment != "production" ? 1 : 0
  
  content  = tls_private_key.application_key.private_key_pem
  filename = "${path.module}/${local.name_prefix}-private-key.pem"
  
  file_permission = "0600"
  
  lifecycle {
    create_before_destroy = true
  }
}

# Output values with descriptions and sensitive markings
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value = [
    for subnet_key, subnet_config in local.public_subnet_configs :
    aws_subnet.subnets[subnet_key].id
  ]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value = [
    for subnet_key, subnet_config in local.private_subnet_configs :
    aws_subnet.subnets[subnet_key].id
  ]
}

output "load_balancer_dns_name" {
  description = "DNS name of the application load balancer"
  value       = aws_lb.application.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the application load balancer"
  value       = aws_lb.application.zone_id
}

output "application_s3_bucket" {
  description = "Name of the application data S3 bucket"
  value       = aws_s3_bucket.application_data.bucket
}

output "auto_scaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.application.arn
}

output "security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.application.id
}

output "iam_role_arn" {
  description = "ARN of the IAM role for instances"
  value       = aws_iam_role.instance_role.arn
}

output "database_password" {
  description = "Generated database password (production only)"
  value       = local.is_production ? random_password.database_password[0].result : null
  sensitive   = true
}

output "private_key_path" {
  description = "Path to the private key file (development only)"
  value       = var.environment != "production" ? local_file.private_key[0].filename : null
  sensitive   = true
}

output "deployment_info" {
  description = "Deployment information and metadata"
  value = {
    environment         = var.environment
    application_name    = var.application_config.name
    application_version = var.application_config.version
    deployment_time     = local.timestamp
    aws_region         = data.aws_region.current.name
    account_id         = data.aws_caller_identity.current.account_id
    is_production      = local.is_production
    enabled_features   = local.enabled_features
  }
}
