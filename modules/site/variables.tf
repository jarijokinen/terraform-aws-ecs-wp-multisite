variable "site_domain_name" {
  description = "The domain name for the WordPress site"
  type        = string
}

variable "lb_secret_header" {
  description = "X-Secret-Header value for the load balancer"
  default     = "secretvalue"
  type        = string
}

variable "lb_dns_name" {
  description = "The DNS name of the load balancer"
  type        = string
}

variable "maintenance_mode_enabled" {
  description = "Enable maintenance mode"
  default     = false
  type        = bool
}
