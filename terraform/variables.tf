variable project {
  description = "Project ID"
}

variable "name" {
  description = "Application name"
}

variable "service_port" {
  description = "Service port"
  default     = "9292"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable "instance_region" {
  description = "Region of the instance"
  default     = "europe-west1-b"
}

variable "count" {
  description = "Count of the instances in the pool"
  default     = 1
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

variable disk_image {
  description = "Disk image"
}
