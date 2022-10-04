

/*
 * Copyright 2017 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * Terraform compute resources for GCP.
 * Acquire all zones and choose one randomly.
 */

data "google_compute_zones" "available" {
  region = var.gcp_region
}

data "google_compute_default_service_account" "default" {
}

output "default_account" {
  value = data.google_compute_default_service_account.default.email
}

resource "google_compute_address" "gcp-ip" {
  name   = "${var.prefix_sa_name}-gce-ip-${var.gcp_region}-1"
  region = var.gcp_region
}

resource "google_compute_instance" "gcp-vm1" {
  name         = "${var.prefix_sa_name}-vm-${var.gcp_region}"
  machine_type = var.gcp_instance_type
  zone         = data.google_compute_zones.available.names[0]

  boot_disk {
    initialize_params {
      image = var.gcp_disk_image
      size  = 200
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.gcp-subnet1.name
    # network_ip = var.gcp_vm_address

    access_config {
      # Static IP
      nat_ip = google_compute_address.gcp-ip.address
    }
  }

  service_account {
    email = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }

  allow_stopping_for_update = true

  metadata = {
    mount_bucket_name = google_storage_bucket.gcs_fuse.name
  }
  metadata_startup_script = "${file("./gcsfuse.sh")}"
}
