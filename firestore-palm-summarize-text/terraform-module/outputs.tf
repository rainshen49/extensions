output "collection_path" {
  description = "What is the path to the collection that contains the strings that you want to translate?"
  value = local.collection_path
}

output "output_field_name" {
  description = "What is the name of the field where you want to store your translations?"
  value = var.output_field_name
}

output "project" {
  description = "The project used by this extensions"
  value = local.project
}

output "location" {
  description = "The location this Extensions runs in"
  value = local.location
}