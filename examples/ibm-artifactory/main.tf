provider "ibm" {}

# Create a new ssh key
resource "ibm_compute_ssh_key" "ssh_key" {
  label      = "${var.ssh-label}"
  notes      = "SSH key for Artifactory HA Cluster"
  public_key = "${var.ssh_public_key}"
}

resource "ibm_compute_ssl_certificate" "ssl_cert" {
  certificate = "${file(var.ssl_certificate)}"
  private_key = "${file(var.ssl_certificate_key)}"
}

resource "ibm_lb" "art_lb" {
  connections = "${var.lb-connections}"
  datacenter  = "${var.datacenter}"
  ha_enabled  = false
  dedicated   = "${var.lb-dedicated}"
  ssl_offload = true
  security_certificate_id = "${ibm_compute_ssl_certificate.ssl_cert.id}"
}

resource "ibm_lb_service_group" "art_lb_service_group" {
  port             = "${var.lb-service-group-port}"
  routing_method   = "${var.lb-service-group-routing-method}"
  routing_type     = "${var.lb-service-group-routing-type}"
  load_balancer_id = "${ibm_lb.art_lb.id}"
  allocation       = "${var.lb-service-group-routing-allocation}"
}

resource "ibm_compute_autoscale_group" "art-primary" {
  name                 = "${var.auto-scale-name}"
  regional_group       = "${var.auto-scale-region}"
  cooldown             = "${var.auto-scale-cooldown}"
  minimum_member_count = "1"
  maximum_member_count = "2"
  termination_policy   = "${var.auto-scale-termination-policy}"
  virtual_server_id    = "${ibm_lb_service_group.art_lb_service_group.id}"
  port                 = "${var.auto-scale-lb-service-port}"

  health_check = {
    type = "${var.auto-scale-lb-service-health-check-type}"
    custom_method = "GET"
    custom_response = "200"
    custom_request = "/artifactory/api/system/version"
  }

  virtual_guest_member_template = {
    hostname                = "${var.vm-hostname}"
    domain                  = "${var.vm-domain}"
    cores                   = "${var.vm-cores}"
    memory                  = "${var.vm-memory}"
    os_reference_code       = "${var.vm-os-reference-code}"
    disks                   = ["${var.vm-disk-size}"]
    datacenter              = "${var.datacenter}"
    ssh_key_ids             = ["${ibm_compute_ssh_key.ssh_key.id}"]
    post_install_script_uri = "${var.vm-post-install-script-uri}"
    user_metadata           = "${data.template_file.art_init.rendered}"
  }
}

resource "ibm_compute_autoscale_group" "art-member" {
  name                 = "${var.auto-scale-member-name}"
  regional_group       = "${var.auto-scale-region}"
  cooldown             = "${var.auto-scale-cooldown}"
  minimum_member_count = "${var.auto-scale-minimum-member-count}"
  maximum_member_count = "${var.auto-scale-maximumm-member-count}"
  termination_policy   = "${var.auto-scale-termination-policy}"
  virtual_server_id    = "${ibm_lb_service_group.art_lb_service_group.id}"
  port                 = "${var.auto-scale-lb-service-port}"

  health_check = {
    type = "${var.auto-scale-lb-service-health-check-type}"
    custom_method = "GET"
    custom_response = "200"
    custom_request = "/artifactory/api/system/version"
  }

  virtual_guest_member_template = {
    hostname                = "${var.vm-hostname-member}"
    domain                  = "${var.vm-domain}"
    cores                   = "${var.vm-cores}"
    memory                  = "${var.vm-memory}"
    os_reference_code       = "${var.vm-os-reference-code}"
    disks                   = ["${var.vm-disk-size}"]
    datacenter              = "${var.datacenter}"
    ssh_key_ids             = ["${ibm_compute_ssh_key.ssh_key.id}"]
    post_install_script_uri = "${var.vm-post-install-script-uri}"
    user_metadata           = "${data.template_file.art_init_member.rendered}"
  }
}

data "template_file" "art_init" {
  template = "${file(var.install_script_path)}"

  vars {
    db_user = "${var.database_user}"
    db_password = "${var.database_password}"
    db_name = "${var.database_name}"
    db_url = "${var.database_url}"
    master_key = "${var.master_key}"
//    ssl_certificate = "${var.ssl_cert}"
//    ssl_certificate_key = "${var.ssl_cert_key}"
    certificate_domain = "${var.certificate_domain}"
    artifactory_server_name = "${var.artifactory_server_name}"
    EXTRA_JAVA_OPTS = "${var.extra_java_options}"
    IS_PRIMARY = "true"
    s3_access_key = "${var.s3_access_key}"
    s3_secret_key = "${var.s3_secret_key}"
    s3_endpoint = "${var.s3_endpoint}"
    s3_bucket_name = "${var.s3_bucket_name}"
  }
}

data "template_file" "art_init_member" {
  template = "${file(var.install_script_path)}"

  vars {
    db_user = "${var.database_user}"
    db_password = "${var.database_password}"
    db_name = "${var.database_name}"
    db_url = "${var.database_url}"
    master_key = "${var.master_key}"
//    ssl_certificate = "${var.ssl_cert}"
//    ssl_certificate_key = "${var.ssl_cert_key}"
    certificate_domain = "${var.certificate_domain}"
    artifactory_server_name = "${var.artifactory_server_name}"
    EXTRA_JAVA_OPTS = "${var.extra_java_options}"
    IS_PRIMARY = "false"
    s3_access_key = "${var.s3_access_key}"
    s3_secret_key = "${var.s3_secret_key}"
    s3_endpoint = "${var.s3_endpoint}"
    s3_bucket_name = "${var.s3_bucket_name}"
  }
}

resource "ibm_compute_autoscale_policy" "art-cluster-policy" {
  name           = "${var.scale-policy-name}"
  scale_type     = "${var.scale-policy-type}"
  scale_amount   = "${var.scale-policy-scale-amount}"
  cooldown       = "${var.scale-policy-cooldown}"
  scale_group_id = "${ibm_compute_autoscale_group.art-member.id}"

  triggers = {
    type = "RESOURCE_USE"

    watches = {
      metric   = "host.cpu.percent"
      operator = ">"
      value    = "90"
      period   = 130
    }
  }
}
