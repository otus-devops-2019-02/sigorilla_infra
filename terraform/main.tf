terraform {
  # Версия terraform
  required_version = "0.11.13"
}

provider "template" {
  version = "2.1.0"
}

provider "google" {
  # Версия провайдера
  version = "2.0.0"

  # ID проекта
  project = "${var.project}"
  region  = "${var.region}"
}

data "template_file" "puma_service" {
  template = "${file("files/puma.service")}"

  vars = {
    user = "${var.user}"
  }
}

resource "google_compute_instance" "app" {
  count        = "${var.count}"
  name         = "${var.name}-app-${count.index}"
  machine_type = "g1-small"
  zone         = "${var.instance_region}"
  tags         = ["${var.name}-firewall-tag"]

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  # определение сетевого интерфейса
  network_interface {
    # сеть, к которой присоединить данный интерфейс
    network = "default"

    # использовать ephemeral IP для доступа из Интернет
    access_config {}
  }

  metadata {
    # путь до публичного ключа
    ssh-keys = "${var.user}:${file(var.public_key_path)}"
  }

  connection {
    type        = "ssh"
    user        = "${var.user}"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "file" {
    content     = "${data.template_file.puma_service.rendered}"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

resource "google_compute_firewall" "default" {
  name = "${var.name}-firewall"

  # Название сети, в которой действует правило
  network = "default"

  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["${var.service_port}"]
  }

  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]

  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["${var.name}-firewall-tag"]
}
