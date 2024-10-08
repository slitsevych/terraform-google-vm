
variable "project_id" {
  type        = string
  description = "The GCP project ID"
  default     = null
}

variable "hostname" {
  description = "Hostname prefix for instances"
  type        = string
  default     = "default"
}

variable "mig_name" {
  type        = string
  description = "Managed instance group name. When variable is empty, name will be derived from var.hostname."
  default     = ""
}

variable "zone" {
  description = "The GCP zone where the managed instance group resides."
  type        = string
}

variable "instance_template" {
  description = "Instance template self_link used to create compute instances"
  type        = string
}

variable "target_size" {
  description = "The target number of running instances for this managed instance group. This value should always be explicitly set unless this resource is attached to an autoscaler, in which case it should never be set."
  type        = number
  default     = 1
}

variable "target_suspended_size" {
  description = "The target number of suspended instances for this managed instance group."
  type        = number
  default     = 0
}

variable "target_stopped_size" {
  description = "The target number of stopped instances for this managed instance group."
  type        = number
  default     = 0
}

variable "target_pools" {
  description = "The target load balancing pools to assign this group to."
  type        = list(string)
  default     = []
}

#################
# Stateful disks
#################
variable "stateful_disks" {
  description = "Disks created on the instances that will be preserved on instance delete. https://cloud.google.com/compute/docs/instance-groups/configuring-stateful-disks-in-migs"
  type = list(object({
    device_name = string
    delete_rule = string
  }))
  default = []
}

#################
# Stateful IPs
#################
variable "stateful_ips" {
  description = "Statful IPs created on the instances that will be preserved on instance delete. https://cloud.google.com/compute/docs/instance-groups/configuring-stateful-ip-addresses-in-migs"
  type = list(object({
    interface_name = string
    delete_rule    = string
    is_external    = bool
  }))
  default = []
}

#################
# Rolling Update
#################

variable "update_policy" {
  description = "The rolling update policy. https://www.terraform.io/docs/providers/google/r/compute_region_instance_group_manager#rolling_update_policy"
  type = list(object({
    max_surge_fixed                = optional(number)
    max_unavailable_fixed          = optional(number)
    min_ready_sec                  = optional(number)
    replacement_method             = optional(string)
    minimal_action                 = string
    type                           = string
    most_disruptive_allowed_action = optional(string)
  }))
  default = []
}

variable "standby_policy" {
  description = "The standby policy. https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group_manager#standby_policy"
  type = list(object({
    initial_delay_sec = optional(number)
    mode              = optional(string)
  }))
  default = []
}

variable "instance_lifecycle_policy" {
  description = "The instance_lifecycle_policy"
  type = list(object({
    force_update_on_repair    = optional(string)
    default_action_on_failure = optional(string)
  }))
  default = []
}

##############
# Healthcheck
##############

variable "health_check_name" {
  type        = string
  description = "Health check name. When variable is empty, name will be derived from var.hostname."
  default     = ""
}

variable "health_check" {
  description = "Health check to determine whether instances are responsive and able to do work"
  type = object({
    type                = optional(string)
    initial_delay_sec   = optional(number)
    check_interval_sec  = optional(number)
    healthy_threshold   = optional(number)
    timeout_sec         = optional(number)
    unhealthy_threshold = optional(number)
    response            = optional(string)
    proxy_header        = optional(string)
    port                = optional(number)
    request             = optional(string)
    request_path        = optional(string)
    host                = optional(string)
    enable_logging      = optional(bool)
  })
  default = {
    type                = ""
    initial_delay_sec   = 30
    check_interval_sec  = 30
    healthy_threshold   = 1
    timeout_sec         = 10
    unhealthy_threshold = 5
    response            = ""
    proxy_header        = "NONE"
    port                = 80
    request             = ""
    request_path        = "/"
    host                = ""
    enable_logging      = false
  }
}

#############
# Autoscaler
#############
variable "autoscaler_name" {
  type        = string
  description = "Autoscaler name. When variable is empty, name will be derived from var.hostname."
  default     = ""
}

variable "autoscaling_enabled" {
  description = "Creates an autoscaler for the managed instance group"
  default     = "false"
  type        = string
}

variable "max_replicas" {
  description = "The maximum number of instances that the autoscaler can scale up to. This is required when creating or updating an autoscaler. The maximum number of replicas should not be lower than minimal number of replicas."
  default     = 10
  type        = number
}

variable "min_replicas" {
  description = "The minimum number of replicas that the autoscaler can scale down to. This cannot be less than 0."
  default     = 2
  type        = number
}

variable "cooldown_period" {
  description = "The number of seconds that the autoscaler should wait before it starts collecting information from a new instance."
  default     = 60
  type        = number
}

variable "autoscaling_mode" {
  description = "Operating mode of the autoscaling policy. If omitted, the default value is ON. https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler#mode"
  type        = string
  default     = null
}

variable "autoscaling_cpu" {
  description = "Autoscaling, cpu utilization policy block as single element array. https://www.terraform.io/docs/providers/google/r/compute_autoscaler#cpu_utilization"
  type = list(object({
    target            = number
    predictive_method = string
  }))
  default = []
}

variable "autoscaling_metric" {
  description = "Autoscaling, metric policy block as single element array. https://www.terraform.io/docs/providers/google/r/compute_autoscaler#metric"
  type = list(object({
    name   = string
    target = number
    type   = string
    single_instance_assignment = number
    filter = string
  }))
  default = []
}

variable "autoscaling_lb" {
  description = "Autoscaling, load balancing utilization policy block as single element array. https://www.terraform.io/docs/providers/google/r/compute_autoscaler#load_balancing_utilization"
  type        = list(map(number))
  default     = []
}

variable "scaling_schedules" {
  description = "Autoscaling, scaling schedule block. https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler#scaling_schedules"
  type = list(object({
    disabled              = bool
    duration_sec          = number
    min_required_replicas = number
    name                  = string
    schedule              = string
    time_zone             = string
  }))
  default = []
}

variable "autoscaling_scale_in_control" {
  description = "Autoscaling, scale-in control block. https://www.terraform.io/docs/providers/google/r/compute_autoscaler#scale_in_control"
  type = object({
    fixed_replicas   = number
    percent_replicas = number
    time_window_sec  = number
  })
  default = {
    fixed_replicas   = null
    percent_replicas = null
    time_window_sec  = null
  }
}

variable "autoscaling_scale_down_control" {
  description = "Autoscaling, scale-down control block. https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler#nested_scale_down_control"
  type = object({
    fixed_replicas   = number
    percent_replicas = number
    time_window_sec  = number
  })
  default = {
    fixed_replicas   = null
    percent_replicas = null
    time_window_sec  = null
  }
}

##########################

variable "named_ports" {
  description = "Named name and named port. https://cloud.google.com/load-balancing/docs/backend-service#named_ports"
  type = list(object({
    name = string
    port = number
  }))
  default = []
}

variable "wait_for_instances" {
  description = "Whether to wait for all instances to be created/updated before returning. Note that if this is set to true and the operation does not succeed, Terraform will continue trying until it times out."
  type        = string
  default     = "false"
}

variable "wait_for_instances_status" {
  description = "When used with wait_for_instances it specifies the status to wait for. When STABLE is specified this resource will wait until the instances are stable before returning. When UPDATED is set, it will wait for the version target to be reached and any per instance configs to be effective as well as all instances to be stable before returning. The possible values are STABLE and UPDATED"
  type        = string
  default     = null
}

variable "mig_timeouts" {
  description = "Times for creation, deleting and updating the MIG resources. Can be helpful when using wait_for_instances to allow a longer VM startup time. "
  type = object({
    create = string
    update = string
    delete = string
  })
  default = {
    create = "5m"
    update = "5m"
    delete = "5m"
  }
}

variable "labels" {
  type        = map(string)
  description = "Labels, provided as a map"
  default     = {}
}
