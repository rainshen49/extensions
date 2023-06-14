variable "project" {
  description = "The ID of the project to create the Cloud Function in."
  type        = string
  nullable    = false
}

variable "source_dir" {
  description = "Path to the directory containing the functions code, such as `/functions`"
  type        = string
  nullable    = false
}

variable "bucket" {
  description = "Google Cloud Storage bucket to use to upload the Cloud Function code."
  type        = string
  nullable    = false
}
