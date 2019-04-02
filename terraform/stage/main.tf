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
  template = "${file("../files/puma.service")}"

  vars = {
    user = "${var.user}"
  }
}

module "app" {
  source = "../modules/app"

  name            = "${var.name}"
  zone            = "${var.zone}"
  count           = "${var.count}"
  user            = "${var.user}"
  public_key_path = "${var.public_key_path}"
  service_port    = "${var.service_port}"
  app_disk_image  = "${var.app_disk_image}"
}

module "db" {
  source = "../modules/db"

  name            = "${var.name}"
  zone            = "${var.zone}"
  user            = "${var.user}"
  public_key_path = "${var.public_key_path}"
  db_disk_image   = "${var.db_disk_image}"
}

module "vpc" {
  source = "../modules/vpc"

  source_ranges = ["0.0.0.0/0"]
}
