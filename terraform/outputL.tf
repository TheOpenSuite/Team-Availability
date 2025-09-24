output "hmis_server_ip" {
  description = "The IP address of the HMIS server."
  value       = libvirt_domain.hmis_vm.network_interface[0].addresses[0]
  depends_on  = [libvirt_domain.hmis_vm]
}
