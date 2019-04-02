resource "google_compute_instance" "app" {
  count = "${var.count}"
  name = "${var.name}-app-${count.index}"
  machine_type = "g1-small"
  zone = "${var.zone}"
  tags = ["${var.name}-app"]

  boot_disk {
    initialize_params {
      image = "${var.app_disk_image}"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = "${google_compute_address.app_ip.address}"
    }
  }

  metadata {
    ssh-keys = "${var.user}:${file(var.public_key_path)}"
  }
}

resource "google_compute_address" "app_ip" {
  name = "${var.name}-app-ip"
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports = ["${var.service_port}"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["${var.name}-app"]
}
