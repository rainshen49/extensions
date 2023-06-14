variable "project" {
  description = "target project for the Extension"
  type        = string
}

variable "src_bucket" {
  description = "Bucket with the Extension Source Code"
  type        = string
}

variable "src_object" {
  description = "Bucket Object name"
  type        = string
}

variable "location" {
  description = "location to deploy functions of the extensions"
  type        = string
  default     = "us-central1"
}

variable "languages" {
  description = "Target languages for Translations, as a list"
  type        = string
  default     = "en,es,de,fr"
}

variable "collection_path" {
  description = "What is the path to the collection that contains the strings that you want to translate?"
  type        = string
  default     = "translations"
}

variable "input_field_name" {
  description = "What is the name of the field that contains the string that you want to translate?"
  type        = string
  default     = "input"
}

variable "output_field_name" {
  description = "What is the name of the field where you want to store your translations?"
  type        = string
  default     = "translated"
}

variable "languages_field_name" {
  description = "What is the name of the field that contains the languages that you want to translate into? This field isx optional. If you don't specify it, the extension will use the languages specified in the LANGUAGES parameter."
  type        = string
  default     = null
}

variable "do_backfill" {
  description = "Should existing documents in the Firestore collection be translated as well?  If you've added new languages since a document was translated, this will fill those in as well."
  type        = string
  default     = false
}
