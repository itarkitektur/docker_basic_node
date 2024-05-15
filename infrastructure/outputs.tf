output "example_public_ip_address" {
  value = azurerm_public_ip.example.ip_address
}

output "azure_dns_zone_nameservers" {
  value = azurerm_dns_zone.keacloud.name_servers
}

