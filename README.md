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

## TODO

* Replace hard-coded values with variables
* CloudFront distributions with caching behavior for actual sites

## Usage

```hcl
module "wp_example_com" {
  source = "github.com/jarijokinen/terraform-aws-ecs-wp-multisite"
  domain_name = "wp.example.com"

  # Optional:

  lb_secret_header = "mysecretvalue" 
  maintenance_mode_enabled = true
  maintenance_mode_allowed_ip = "88.123.123.123"
}
```

## License

MIT License. Copyright (c) 2025 [Jari Jokinen](https://jarijokinen.com). See
[LICENSE](https://github.com/jarijokinen/terraform-aws-ecs-wp-multisite/blob/main/LICENSE.txt)
for further details.
