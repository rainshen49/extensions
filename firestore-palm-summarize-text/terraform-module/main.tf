locals {
  project = coalesce(var.pipe.project, var.project)
  location = coalesce(var.pipe.location, var.location)
  collection_path = coalesce(var.pipe.collection_path, var.collection_path)
  input_field_name = coalesce(var.pipe.output_field_name, var.input_field_name)
}

# enable PaLM API
resource "google_project_service" "summarize-ext" {
  provider           = google-beta
  project            = var.project
  service            = "generativelanguage.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "summarize-cf" {
  provider           = google-beta
  project            = var.project
  service            = "cloudfunctions.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "summarize-ar" {
  provider           = google-beta
  project            = var.project
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "summarize-cb" {
  provider           = google-beta
  project            = var.project
  service            = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "firestore-summarize-text" {
  project      = var.project
  account_id   = "ext-firestore-summarize-text"
  display_name = "Firebase Extensions firestore-summarize-text service account"
}

resource "google_project_iam_member" "summarize-text-account" {
  project    = var.project
  role       = "roles/datastore.user"
  member     = "serviceAccount:${google_service_account.firestore-summarize-text.email}"
  depends_on = [google_service_account.firestore-summarize-text]
}

resource "google_cloudfunctions_function" "firestore_summarize" {
  name        = "ext-firestore-palm-summarize-text-generateSummary"
  description = "Firebase Cloud Functions for the Firestore Summarize Text Extension"
  entry_point = "generateSummary"
  environment_variables = {
    "COLLECTION_NAME"   = local.collection_path
    "DATABASE_INSTANCE" = ""
    "DATABASE_URL"      = ""
    "EXT_INSTANCE_ID"   = "firestore-palm-summarize-text"
    "FIREBASE_CONFIG" = jsonencode(
      {
        databaseURL   = ""
        projectId     = local.project
        storageBucket = var.storage_bucket_object.bucket
      }
    )
    "GCLOUD_PROJECT"        = local.project
    "TEXT_FIELD"            = local.input_field_name
    "LOCATION"              = local.location
    "RESPONSE_FIELD"        = var.output_field_name
    "PROJECT_ID"            = local.project
    "STORAGE_BUCKET"        = var.storage_bucket_object.bucket
    "TARGET_SUMMARY_LENGTH" = var.target_summary_length
  }
  ingress_settings = "ALLOW_INTERNAL_ONLY"
  labels = {
    "deployment-tool"        = "firebase-extensions"
    "firebase-extensions-ar" = "enabled"
    "goog-dm"                = "firebase-ext-firestore-palm-summarize-text"
    "goog-firebase-ext"      = "firestore-palm-summarize-text"
    "goog-firebase-ext-iid"  = "firestore-palm-summarize-text"
  }
  project               = local.project
  region                = local.location
  runtime               = "nodejs16"
  service_account_email = google_service_account.firestore-summarize-text.email

  source_archive_bucket = var.storage_bucket_object.bucket
  #   source_archive_bucket = "firebase-mod-sources-prod"
  source_archive_object = var.storage_bucket_object.name

  event_trigger {
    event_type = "providers/cloud.firestore/eventTypes/document.write"
    resource   = "projects/${local.project}/databases/(default)/documents/${local.collection_path}/{messageId}"
  }
  depends_on = [google_project_service.summarize-ext, google_project_iam_member.summarize-text-account]
}
