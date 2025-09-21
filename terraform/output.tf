output "server_identifier" {
  description = "The unique identifier for the server."
  value       = random_pet.server_name.id
}

output "configuration_file_content" {
  description = "Content written to the configuration file."
  value       = local_file.config_file.content
}
