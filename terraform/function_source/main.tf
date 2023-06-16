data "archive_file" "functions" {
  type        = "zip"
  output_path = "${path.module}/${var.source_dir}.zip"
  source_dir = var.source_dir
}

resource "google_storage_bucket_object" "object" {
  name   = "${data.archive_file.functions.output_sha}.zip"
  bucket = var.bucket
  source = data.archive_file.functions.output_path
}

