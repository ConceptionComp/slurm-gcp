# Copyright (C) SchedMD LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

###########
# GENERAL #
###########

project_id = "conception-automation"
zone       = "us-central1-a"

#########
# IMAGE #
#########

# NOTE: Your Project ID will be automatically appended
# source_image_project_id = [
#   # "rhel-cloud",
#   # "centos-cloud",
#   # "cloud-hpc-image-public",
#   "debian-cloud",
#   "ubuntu-os-cloud",
# ]

source_image_project_id = "ubuntu-os-cloud"
source_image_family = "ubuntu-2004-lts"


# *NOT* intended for production use
# skip_create_image = true

###########
# NETWORK #
###########

network_project_id = "conception-shared-vpc"
# network    = "conception-automation-vpc"
# subnetwork = "conception-automation-subnet"
subnetwork = "conception-automation-us-central1-subnet"

use_iap = true


tags = [
  # "tag0",
  # "tag1",
]

#############
# PROVISION #
#############

# slurm_version = "22.05.8"

# Disable some ansible roles here; they are enabled by default
install_cuda = true
# install_ompi = false
# install_lustre = false
# install_gcsfuse = false

prefix = "conception"

##########
# BUILDS #
##########

### Service Account ###

service_account_email = "packer@conception-automation.iam.gserviceaccount.com"

service_account_scopes = [
  "https://www.googleapis.com/auth/cloud-platform",
  "https://www.googleapis.com/auth/devstorage.full_control",
]

### Builds ###

builds = [
  # {
  #   ### image ###
  #   source_image        = null
  #   source_image_family = "centos-7"
  #   image_licenses      = null
  #   labels              = null

  #   ### ssh ###
  #   ssh_username = "packer"
  #   ssh_password = null

  #   ### instance ###
  #   machine_type = "n1-standard-4"
  #   preemptible  = false

  #   ### root of trust ###
  #   enable_secure_boot          = null
  #   enable_vtpm                 = null
  #   enable_integrity_monitoring = null

  #   ### storage ###
  #   disk_size = 32
  #   disk_type = null
  # },
  # {
  #   ### image ###
  #   source_image        = null
  #   source_image_family = "hpc-centos-7"
  #   image_licenses      = null
  #   labels              = null

  #   ### ssh ###
  #   ssh_username = "packer"
  #   ssh_password = null

  #   ### instance ###
  #   machine_type = "n1-standard-4"
  #   preemptible  = false

  #   ### root of trust ###
  #   enable_secure_boot          = null
  #   enable_vtpm                 = null
  #   enable_integrity_monitoring = null

  #   ### storage ###
  #   disk_size = 32
  #   disk_type = null
  # },
  # {
  #   ### image ###
  #   source_image        = null
  #   source_image_family = "debian-11"
  #   image_licenses      = null
  #   labels              = null

  #   ### ssh ###
  #   ssh_username = "packer"
  #   ssh_password = null

  #   ### instance ###
  #   machine_type = "e2-standard-2"
  #   preemptible  = false

  #   ### root of trust ###
  #   enable_secure_boot          = null
  #   enable_vtpm                 = null
  #   enable_integrity_monitoring = null

  #   ### storage ###
  #   disk_size = 32
  #   disk_type = null
  # },
  {
    ### image ###
    source_image        = null
    source_image_family = "ubuntu-2004-lts"
    image_licenses      = null
    labels              = null

    ### ssh ###
    ssh_username = "packer"
    ssh_password = null

    ### instance ###
    machine_type = "n2-standard-4"
    preemptible  = false

    ### root of trust ###
    enable_secure_boot          = null
    enable_vtpm                 = null
    enable_integrity_monitoring = null

    ### storage ###
    disk_size = 32
    disk_type = "pd-ssd"
  },
]

# add extra verbosity arguments to ensure stdout/stderr appear in output
extra_ansible_provisioners = [
  #  {
  #    playbook_file = "/home/user/playbooks/custom.yaml"
  #    galaxy_file = null
  #    extra_arguments = ["-vv"]
  #    user = null
  #  },
]
