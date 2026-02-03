variable "domain_name" {
  description = "The domain name for the WordPress site"
  type        = string
}

variable "lb_secret_header" {
  description = "X-Secret-Header value for the load balancer"
  default     = "secretvalue"
  type        = string
}

variable "maintenance_mode_enabled" {
  description = "Enable maintenance mode"
  default     = false
  type        = bool
}

variable "maintenance_mode_allowed_ip" {
  description = "IP address allowed to access the site in the maintenance mode"
  default     = "127.0.0.1"
  type        = string
}

variable "sites" {
  description = "List of sites to deploy"
  type = list(object({
    domain_name = string
  }))
}

variable "oidc_provider_arn" {
  description = "ARN of the existing OIDC provider"
  type        = string
}

variable "oidc_subjects" {
  type        = list(string)
  description = "OIDC subjects"
}
