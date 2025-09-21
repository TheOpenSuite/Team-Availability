resource "random_pet" "server_name" {
  prefix = "web-app"
  length = 5
}

resource "local_file" "config_file" {
  filename = "server_config.txt"
  content  = "The web server is named: ${random_pet.server_name.id}"
}
