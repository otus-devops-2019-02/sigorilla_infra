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

module "app" {
  source = "../modules/app"

  name             = "${var.name}"
  zone             = "${var.zone}"
  count            = "${var.count}"
  user             = "${var.user}"
  public_key_path  = "${var.public_key_path}"
  private_key_path = "${var.private_key_path}"
  service_port     = "${var.service_port}"
  app_disk_image   = "${var.app_disk_image}"
  db_url           = "${module.db.db_external_ip}:${var.db_port}"
}

module "db" {
  source = "../modules/db"

  name             = "${var.name}"
  zone             = "${var.zone}"
  user             = "${var.user}"
  public_key_path  = "${var.public_key_path}"
  private_key_path = "${var.private_key_path}"
  db_disk_image    = "${var.db_disk_image}"
  db_port          = "${var.db_port}"
}

module "vpc" {
  source = "../modules/vpc"

  source_ranges = ["${var.my_ip}/32"]
}
