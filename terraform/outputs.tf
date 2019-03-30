output "app_external_ip" {
  value = "${google_compute_instance.app.*.network_interface.0.access_config.0.nat_ip}"
}

output "lb_external_ip" {
  description = "The external ip address of the forwarding rule."
  value       = "${google_compute_forwarding_rule.default.ip_address}"
}
