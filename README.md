# terraform-aws-ecs-wp-multisite

Terraform module to create a WordPress Multisite installation on AWS ECS with
EC2, RDS, EFS and CloudFront.

## Features

* VPC with public and private subnets, NAT gateway and Internet Gateway
* ECS cluster with EC2 instances
* ECR for storing the WordPress Docker image
* RDS multi-AZ MySQL database
* EFS file system for WordPress uploads directory
* ACM for certificate management

* CloudFront Functions request handler for enabling maintenance mode
* Ability to whitelist an IP address to allow admin access in maintenance mode

* OIDC support for CI/CD pushes to ECR

## TODO

* Replace hard-coded values with variables
* Add caching for production sites

## Usage

```hcl
# OIDC configuration to allow GitHub Actions to push images to ECR

data "tls_certificate" "gha" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.gha.certificates[0].sha1_fingerprint]

  lifecycle {
    prevent_destroy = true
  }
}

# Actual module configuration

module "wp_example_com" {
  source = "github.com/jarijokinen/terraform-aws-ecs-wp-multisite"
  domain_name = "wp.example.com"

  oidc_provider_arn = aws_iam_openid_connect_provider.github.arn
  oidc_subjects = [
    "repo:OWNER/REPO:ref:refs/heads/main"
  ]

  # Optional:

  lb_secret_header = "mysecretvalue" 
  maintenance_mode_enabled = true
  maintenance_mode_allowed_ip = "88.123.123.123"

  sites = [
    { domain_name = "www.example.com" },
    { domain_name = "blog.example.net" }
  ]
}
```

## License

MIT License. Copyright (c) 2025 - 2026 [Jari Jokinen](https://jarijokinen.com).
See [LICENSE](https://github.com/jarijokinen/terraform-aws-ecs-wp-multisite/blob/main/LICENSE.txt) for further details.
