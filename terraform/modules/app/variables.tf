variable "name" {
  description = "Application name"
}

variable "service_port" {
  description = "Service port"
}

variable "zone" {
  description = "Region of the instance"
}

variable "count" {
  description = "Count of the instances in the pool"
}

variable "user" {
  description = "User for connection"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable app_disk_image {
  description = "Disk image"
}
