module "site" {
  for_each = { for site in var.sites : site.domain_name => site }

  source = "./modules/site"

  site_domain_name         = each.value.domain_name
  lb_secret_header         = var.lb_secret_header
  lb_dns_name              = aws_lb.wp.dns_name
  maintenance_mode_enabled = var.maintenance_mode_enabled
}
