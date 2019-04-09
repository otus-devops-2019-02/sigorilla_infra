variable "name" {
  description = "Application name"
}

variable "zone" {
  description = "Region of the instance"
}

variable "user" {
  description = "User for connection"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
}

variable db_disk_image {
  description = "DB disk image"
}

variable "db_port" {
  description = "DB port"
}
