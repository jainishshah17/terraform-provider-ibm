provider "ibm" {}

# Create a new ssh key 
resource "ibm_compute_ssh_key" "ssh_key" {
  label      = "${var.ssh-label}"
  notes      = "for scale group"
  public_key = "${var.ssh_public_key}"
}

resource "ibm_lb" "art_local_lb" {
  connections = "${var.lb-connections}"
  datacenter  = "${var.datacenter}"
  ha_enabled  = false
  dedicated   = "${var.lb-dedicated}"
}

resource "ibm_lb_service_group" "art_lb_service_group" {
  port             = "${var.lb-servvice-group-port}"
  routing_method   = "${var.lb-servvice-group-routing-method}"
  routing_type     = "${var.lb-servvice-group-routing-type}"
  load_balancer_id = "${ibm_lb.art_local_lb.id}"
  allocation       = "${var.lb-servvice-group-routing-allocation}"
}

resource "ibm_compute_autoscale_group" "art-cluster" {
  name                 = "${var.auto-scale-name}"
  regional_group       = "${var.auto-scale-region}"
  cooldown             = "${var.auto-scale-cooldown}"
  minimum_member_count = "${var.auto-scale-minimum-member-count}"
  maximum_member_count = "${var.auto-scale-maximumm-member-count}"
  termination_policy   = "${var.auto-scale-termination-policy}"
  virtual_server_id    = "${ibm_lb_service_group.art_lb_service_group.id}"
  port                 = "${var.auto-scale-lb-service-port}"

  health_check = {
    type = "${var.auto-scale-lb-service-health-check-type}"
  }

  virtual_guest_member_template = {
    hostname                = "${var.vm-hostname}"
    domain                  = "${var.vm-domain}"
    cores                   = "${var.vm-cores}"
    memory                  = "${var.vm-memory}"
    os_reference_code       = "${var.vm-os-reference-code}"
    datacenter              = "${var.datacenter}"
    ssh_key_ids             = ["${ibm_compute_ssh_key.ssh_key.id}"]
    post_install_script_uri = "${var.vm-post-install-script-uri}"
    user_metadata           = "${data.template_file.art_init.rendered}"
  }
}

data "template_file" "art_init" {
  template = "${file("scripts/install.yml")}"

  vars {
    db_user = "${var.database_user}"
    db_password = "${var.database_password}"
    db_name = "${var.database_name}"
    db_url = "${var.database_url}"
  }
}

resource "ibm_compute_autoscale_policy" "art-cluster-policy" {
  name           = "${var.scale-policy-name}"
  scale_type     = "${var.scale-policy-type}"
  scale_amount   = "${var.scale-policy-scale-amount}"
  cooldown       = "${var.scale-policy-cooldown}"
  scale_group_id = "${ibm_compute_autoscale_group.art-cluster.id}"

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
