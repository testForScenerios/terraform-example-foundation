/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  dns_hub_project_id = data.google_projects.dns_hub.projects[0].project_id
}

data "google_active_folder" "bootstrap" {
  display_name = "${var.folder_prefix}-bootstrap"
  parent       = local.parent_id
}

data "google_active_folder" "sandbox" {
  display_name = "${var.folder_prefix}-sandbox"
  parent       = local.parent_id
}

data "google_active_folder" "production" {
  display_name = "${var.folder_prefix}-production"
  parent       = local.parent_id
}

data "google_active_folder" "non-production" {
  display_name = "${var.folder_prefix}-non-production"
  parent       = local.parent_id
}

/******************************************
  DNS Hub Project
*****************************************/

data "google_projects" "dns_hub" {
  filter = "parent.id:${split("/", data.google_active_folder.common.name)[1]} labels.application_name=org-dns-hub lifecycleState=ACTIVE"
}

/******************************************
  Default DNS Policy
 *****************************************/

resource "google_dns_policy" "default_policy" {
  project                   = local.dns_hub_project_id
  name                      = "dp-dns-hub-default-policy"
  enable_inbound_forwarding = true
  enable_logging            = var.dns_enable_logging
  networks {
    network_url = module.nethub_shared_vpc.network_self_link
  }
}

/******************************************
 DNS Forwarding
*****************************************/

module "dns-forwarding-zone" {
  source  = "terraform-google-modules/cloud-dns/google"
  version = "3.0.2"

  project_id = local.dns_hub_project_id
  type       = "forwarding"
  name       = "fz-dns-hub"
  domain     = var.domain

  private_visibility_config_networks = [
    module.nethub_shared_vpc.network_self_link
  ]
  target_name_server_addresses = var.target_name_server_addresses
}

