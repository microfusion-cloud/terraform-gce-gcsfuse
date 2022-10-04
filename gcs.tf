resource "google_storage_bucket" "gcs_fuse" {
  name          = "${var.prefix_sa_name}-gcsfuse-test"
  location      = var.gcp_region
  force_destroy = true

  uniform_bucket_level_access = true
}