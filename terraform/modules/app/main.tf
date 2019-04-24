data "template_file" "puma_service" {
  template = "${file("${path.module}/files/puma.service")}"

  vars = {
    user = "${var.user}"
  }
}

data "template_file" "puma_env" {
  template = "${file("${path.module}/files/puma.env")}"

  vars = {
    db_url = "${var.db_url}"
  }
}

resource "google_compute_instance" "app" {
  count        = "${var.count}"
  name         = "${var.name}-app-${count.index}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["${var.name}-app"]

  boot_disk {
    initialize_params {
      image = "${var.app_disk_image}"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = "${element(google_compute_address.app_ip.*.address, count.index)}"
    }
  }

  metadata {
    ssh-keys = "${var.user}:${file(var.public_key_path)}"
  }

  connection {
    type        = "ssh"
    user        = "${var.user}"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  # provisioner "file" {
  #   content     = "${data.template_file.puma_service.rendered}"
  #   destination = "/tmp/puma.service"
  # }

  # provisioner "file" {
  #   content     = "${data.template_file.puma_env.rendered}"
  #   destination = "/tmp/puma.env"
  # }

  # provisioner "remote-exec" {
  #   script = "${path.module}/files/deploy.sh"
  # }
}

resource "google_compute_address" "app_ip" {
  count = "${var.count}"
  name  = "${var.name}-app-ip-${count.index}"
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["${var.service_port}", "80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.name}-app"]
}
