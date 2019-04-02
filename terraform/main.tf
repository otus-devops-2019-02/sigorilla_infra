terraform {
  # Версия terraform
  required_version = ">=0.11,<= 0.12"
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
