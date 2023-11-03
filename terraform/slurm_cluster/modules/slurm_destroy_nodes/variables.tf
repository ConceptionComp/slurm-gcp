/**
 * Copyright (C) SchedMD LLC.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "slurm_cluster_name" {
  description = "Destroy compute nodes labeled with this slurm_cluster_name."
  type        = string

  validation {
    condition     = length(var.slurm_cluster_name) > 0
    error_message = "The slurm_cluster_name must not be empty."
  }
}

variable "project_id" {
  description = "The project ID"
  type        = string

  validation {
    condition     = length(var.project_id) > 0
    error_message = "The project_id must not be empty."
  }
}

variable "triggers" {
  description = "Additional Terraform triggers."
  type        = map(string)
  default     = {}
}

variable "target_list" {
  description = "Target destruction of these compute nodes, by instance name."
  type        = list(string)
  default     = []
}

variable "exclude_list" {
  description = "Exclude destruction of these compute nodes, by instance name."
  type        = list(string)
  default     = []
}

variable "when_destroy" {
  description = "Run only on `terraform destroy`?"
  type        = bool
  default     = false
}
