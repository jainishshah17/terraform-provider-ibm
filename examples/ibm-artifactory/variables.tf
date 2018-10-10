variable "ssh_public_key" {
}

variable "master_key" {
  default = "35767fa0164bac66b6cccb8880babefb"
}

variable "database_url" {
}

variable "database_name" {
}

variable "database_user" {
  default = "artifactory"
}

variable "database_password" {
  default = "password"
}

variable "extra_java_options" {
  default = "-server -Xms2g -Xmx4g -Xss256k -XX:+UseG1GC -XX:OnOutOfMemoryError=\\\\\\\"kill -9 %p\\\\\\\""
  description = "Setting Java Memory Parameters for Artifactory. Learn about system requirements for Artifactory https://www.jfrog.com/confluence/display/RTF/System+Requirements#SystemRequirements-RecommendedHardware."
}

variable "ssl_certificate" {
  description = "To use Artifactory as docker registry you need to provide wild card valid Certificate. Provide your SSL Certificate."
}

variable "ssl_certificate_key" {
  description = "Provide your SSL Certificate key"
}

variable "certificate_domain" {
  description = "Provide your Certificate Domain Name. For e.g jfrog.team for certificate with *.jfrog.team"
  default = "artifactory"
}

variable "artifactory_server_name" {
  description = "Provide artifactory server name to be used in Nginx. e.g artifactory for artifactory.jfrog.team"
  default = "artifactory"
}

variable "ssh-label" {
  default = "ssh_key_scale_group"
}

variable "lb-connections" {
  default = 250
}

variable "datacenter" {
  default = "dal09"
}

variable "lb-dedicated" {
  default = false
}

variable "lb-service-group-port" {
  default = 80
}

variable "lb-service-group-routing-method" {
  default = "CONSISTENT_HASH_IP"
}

variable "lb-service-group-routing-type" {
  default = "HTTPS"
}

variable "lb-service-group-routing-allocation" {
  default = 100
}

variable "auto-scale-name" {
  default = "art-cluster"
}

variable "auto-scale-member-name" {
  default = "art-cluster-member"
}

variable "auto-scale-region" {
  default = "na-usa-central-1"
}

variable "auto-scale-cooldown" {
  default = 30
}

variable "auto-scale-minimum-member-count" {
  default = 1
}

variable "auto-scale-maximumm-member-count" {
  default = 10
}

variable "auto-scale-termination-policy" {
  default = "CLOSEST_TO_NEXT_CHARGE"
}

variable "auto-scale-lb-service-port" {
  default = 80
}

variable "auto-scale-lb-service-health-check-type" {
  default = "HTTP-CUSTOM"
}

variable "vm-hostname" {
  default = "artifactory"
}

variable "vm-hostname-member" {
  default = "artifactory-member"
}

variable "vm-domain" {
  default = "art.com"
}

variable "vm-cores" {
  default = 4
}

variable "vm-memory" {
  default = 4096
}

variable "vm-disk-size" {
  description = "Disk size for each instance"
  default = 25
}

variable "vm-os-reference-code" {
  default = "UBUNTU_14_64"
}

variable "vm-post-install-script-uri" {
  default = "https://raw.githubusercontent.com/jainishshah17/terraform-provider-ibm/master/examples/ibm-artifactory/artifactory.sh"
}

variable "scale-policy-name" {
  default = "art-scale-policy"
}

variable "scale-policy-type" {
  default = "ABSOLUTE"
}

variable "scale-policy-scale-amount" {
  default = 2
}

variable "scale-policy-cooldown" {
  default = 35
}
