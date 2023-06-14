output "bucket" {
  value = google_storage_bucket_object.object.bucket
}

output "object" {
  value = google_storage_bucket_object.object.output_name
}

output "sha1_hash" {
  value = data.archive_file.functions.output_sha
}
