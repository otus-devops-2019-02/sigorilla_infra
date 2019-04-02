resource "google_compute_instance" "db" {
  name = "${var.name}-db"
  machine_type = "g1-small"
  zone = "${var.zone}"
  tags = ["${var.name}-db"]

  boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata {
    ssh-keys = "${var.user}:${file(var.public_key_path)}"
  }
}

resource "google_compute_firewall" "firewall_mongo" {
  name = "allow-mongo-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports = ["27017"]
  }
  target_tags = ["${var.name}-db"]
  source_tags = ["${var.name}-app"]
}
