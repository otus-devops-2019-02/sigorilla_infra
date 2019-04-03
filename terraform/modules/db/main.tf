data "template_file" "mongod_conf" {
  template = "${file("${path.module}/files/mongod.conf")}"

  vars = {
    db_port = "${var.db_port}"
  }
}

resource "google_compute_instance" "db" {
  name         = "${var.name}-db"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["${var.name}-db"]

  boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
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

  provisioner "file" {
    content     = "${data.template_file.mongod_conf.rendered}"
    destination = "/tmp/mongod.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/mongod.conf /etc/mongod.conf",
      "sudo systemctl restart mongod",
    ]
  }
}

resource "google_compute_firewall" "firewall_mongo" {
  name    = "allow-mongo-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["${var.db_port}"]
  }

  target_tags = ["${var.name}-db"]
  source_tags = ["${var.name}-app"]
}
