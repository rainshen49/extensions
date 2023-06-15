variable "project" {
  description = "target project for the Extension"
  type        = string
}


variable "storage_bucket_object" {
  type = object({
    name = string
    bucket = string
  })

  default = {
    name = "d71edbbf7a44da5b415a18cffbf8f3b043f25dded22d993d8c5592b263e6139c"
    bucket = "firebase-mod-sources-prod"
  }
}

variable "location" {
  description = "location to deploy functions of the extensions"
  type        = string
  default     = "us-central1"
}

variable "target_summary_length" {
  description = "Number of sentences you would like the summary to be."
  type        = string
  default     = "10"
}

variable "collection_path" {
  description = "Path to the Firestore collection where messages will be generated"
  type        = string
  default     = "raw_text"
}

variable "input_field_name" {
  description = "The field of the document containing text to summarize"
  type        = string
  default     = "input"
}

variable "output_field_name" {
  description = "The field in the message document into which to put the response"
  type        = string
  default     = "output"
}