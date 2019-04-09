terraform {
  backend "gcs" {
    bucket = "storage-bucket-sigorilla-test"
    prefix = "terraform/state/prod"
  }
}
