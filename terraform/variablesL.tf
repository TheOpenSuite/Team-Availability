variable "image_source_path" {
  description = "Path to the base Ubuntu cloud image."
  type        = string
  default     = "/var/lib/libvirt/images/jammy-server-cloudimg-amd64.img"
}

variable "volume_name" {
  description = "The name for the Libvirt volume."
  type        = string
  default     = "hmis-os-volume"
}

variable "cloudinit_name" {
  description = "The name for the cloud-init template."
  type        = string
  default     = "common-init"
}

variable "hostname" {
  description = "The hostname for the virtual machine."
  type        = string
  default     = "hmis-server"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key for user 'ubuntu'."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "vm_memory" {
  description = "Memory in MB for the virtual machine."
  type        = number
  default     = 4096
}

variable "vm_vcpu" {
  description = "Number of vCPUs for the virtual machine."
  type        = number
  default     = 2
}
