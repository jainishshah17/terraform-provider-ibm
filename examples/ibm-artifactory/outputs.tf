#ip_address - cluster address
output "art_address" {
  value = "http://${ibm_lb.art_lb.ip_address}"
}