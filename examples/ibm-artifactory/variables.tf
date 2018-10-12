variable "ssh_public_key" {
  description = "SSH public key for each VMs."
}

variable "master_key" {
  description = "Master key for Artifactory cluster. Generate master.key using command '$openssl rand -hex 16'"
  default = "35767fa0164bac66b6cccb8880babefb"
}

variable "database_url" {
  description = "Database Connection URL. e.g my.databse.com:3306"
}

variable "database_name" {
  description = "Database name"
  default = "artdb"
}

variable "database_user" {
  description = "Database user name"
  default = "artifactory"
}

variable "database_password" {
  description = "Database password"
  default = "password"
}

variable "s3_access_key" {
  description = "Provide Access key to access S3 bucket."
}

variable "s3_secret_key" {
  description = "Provide Secret key to access S3 bucket."
}

variable "s3_endpoint" {
  description = "Provide IBM cloud object storage endpoint url. e.g. s3-api.dal-us-geo.objectstorage.softlayer.net"
}

variable "s3_bucket_name" {
  description = "Provide S3 bucket name."
  default = "art-ent"
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

//variable "ssl_cert" {
//  description = "To use Artifactory as docker registry you need to provide wild card valid Certificate. Provide your SSL Certificate."
//}
//
//variable "ssl_cert_key" {
//  description = "Provide your SSL Certificate key"
//}

variable "certificate_domain" {
  description = "Provide your Certificate Domain Name. For e.g jfrog.team for certificate with *.jfrog.team"
  default = "artifactory"
}

variable "artifactory_server_name" {
  description = "Provide artifactory server name to be used in Nginx. e.g artifactory for artifactory.jfrog.team"
  default = "artifactory"
}

variable "install_script_path" {
  description = "Change script to \"scripts/install_with_s3.yml\" if using IBM Object Storage."
  default = "scripts/install.yml"
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
  default = "jfrog.team"
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
