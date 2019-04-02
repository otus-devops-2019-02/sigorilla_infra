resource "google_compute_forwarding_rule" "default" {
  name                  = "${var.name}-forward-rule"
  target                = "${google_compute_target_pool.default.self_link}"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "${var.service_port}"
}

resource "google_compute_target_pool" "default" {
  name = "${var.name}-pool"

  instances = [
    "${google_compute_instance.app.*.self_link}",
  ]

  health_checks = [
    "${google_compute_http_health_check.default.name}",
  ]
}

resource "google_compute_http_health_check" "default" {
  name               = "${var.name}-health-check"
  port               = "${var.service_port}"
  check_interval_sec = 1
  timeout_sec        = 1
}
