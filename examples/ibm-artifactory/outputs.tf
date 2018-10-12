#ip_address - cluster address
output "artifactory_url" {
  value = "http://${ibm_lb.art_lb.ip_address}"
}