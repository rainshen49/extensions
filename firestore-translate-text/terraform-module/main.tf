locals {
  project = coalesce(var.pipe.project, var.project)
  location = coalesce(var.pipe.location, var.location)
  collection_path = coalesce(var.pipe.collection_path, var.collection_path)
  input_field_name = coalesce(var.pipe.output_field_name, var.input_field_name)
}

# enable translate API
resource "google_project_service" "translate-ext" {
  provider           = google-beta
  project            = local.project
  service            = "translate.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "translate-cf" {
  provider           = google-beta
  project            = local.project
  service            = "cloudfunctions.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "translate-ar" {
  provider           = google-beta
  project            = local.project
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "translate-cb" {
  provider           = google-beta
  project            = local.project
  service            = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "firestore-translate-text" {
  project      = local.project
  account_id   = "ext-firestore-translate-tf"
  display_name = "Firebase Extensions firestore-translate-text service account"
}

resource "google_project_iam_member" "translate-text-account" {
  project = local.project
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.firestore-translate-text.email}"
}

resource "google_cloudfunctions_function" "firestore_translate" {
  name        = "ext-firestore-translate-text-fstranslate"
  description = "Firebase Cloud Functions for the Firestore Translate Text in Firestore Extension"
  entry_point = "fstranslate"
  environment_variables = {
    "COLLECTION_PATH"   = local.collection_path
    "DATABASE_INSTANCE" = ""
    "DATABASE_URL"      = ""
    "DO_BACKFILL"       = var.do_backfill
    "EXT_INSTANCE_ID"   = "firestore-translate-text"
    "FIREBASE_CONFIG" = jsonencode(
      {
        databaseURL   = ""
        projectId     = local.project
        storageBucket = var.storage_bucket_object.bucket
      }
    )
    "GCLOUD_PROJECT"       = local.project
    "INPUT_FIELD_NAME"     = local.input_field_name
    "LANGUAGES"            = var.languages
    "LANGUAGES_FIELD_NAME" = var.languages_field_name
    "LOCATION"             = local.location
    "OUTPUT_FIELD_NAME"    = var.output_field_name

    "PROJECT_ID"     = local.project
    "STORAGE_BUCKET" = var.storage_bucket_object.bucket
  }
  ingress_settings = "ALLOW_INTERNAL_ONLY"
  labels = {
    "deployment-tool"        = "firebase-extensions"
    "firebase-extensions-ar" = "enabled"
    "goog-dm"                = "firebase-ext-firestore-translate-text"
    "goog-firebase-ext"      = "firestore-translate-text"
    "goog-firebase-ext-iid"  = "firestore-translate-text"
  }
  project               = local.project
  region                = local.location
  runtime               = "nodejs16"
  service_account_email = google_service_account.firestore-translate-text.email

  source_archive_bucket = var.storage_bucket_object.bucket
  #   source_archive_bucket = "firebase-mod-sources-prod"
  source_archive_object = var.storage_bucket_object.name

  event_trigger {
    event_type = "providers/cloud.firestore/eventTypes/document.write"
    resource   = "projects/${local.project}/databases/(default)/documents/${local.collection_path}/{messageId}"
  }
  depends_on = [google_project_service.translate-ext, google_project_iam_member.translate-text-account]
}


resource "google_cloudfunctions_function" "firestore_translate_backfill" {
  name        = "ext-firestore-translate-text-fstranslatebackfill"
  description = "Firebase Cloud Functions for the Firestore Translate Text in Firestore Extension Backfill"
  entry_point = "fstranslatebackfill"
  environment_variables = {
    "COLLECTION_PATH"   = local.collection_path
    "DATABASE_INSTANCE" = ""
    "DATABASE_URL"      = ""
    "DO_BACKFILL"       = var.do_backfill
    "EXT_INSTANCE_ID"   = "firestore-translate-text"
    "FIREBASE_CONFIG" = jsonencode(
      {
        databaseURL   = ""
        projectId     = local.project
        storageBucket = var.storage_bucket_object.bucket
      }
    )
    "GCLOUD_PROJECT"       = local.project
    "INPUT_FIELD_NAME"     = local.input_field_name
    "LANGUAGES"            = var.languages
    "LANGUAGES_FIELD_NAME" = var.languages_field_name
    "LOCATION"             = local.location
    "OUTPUT_FIELD_NAME"    = var.output_field_name

    "PROJECT_ID"     = local.project
    "STORAGE_BUCKET" = var.storage_bucket_object.bucket
  }
  ingress_settings = "ALLOW_INTERNAL_ONLY"
  labels = {
    "deployment-tool"        = "firebase-extensions"
    "firebase-extensions-ar" = "enabled"
    "goog-dm"                = "firebase-ext-firestore-translate-text"
    "goog-firebase-ext"      = "firestore-translate-text"
    "goog-firebase-ext-iid"  = "firestore-translate-text"
  }
  project               = local.project
  region                = local.location
  runtime               = "nodejs16"
  service_account_email = google_service_account.firestore-translate-text.email

  source_archive_bucket = var.storage_bucket_object.bucket
  #   source_archive_bucket = "firebase-mod-sources-prod"
  source_archive_object = var.storage_bucket_object.name

  event_trigger {
    event_type = "providers/cloud.firestore/eventTypes/document.write"
    resource   = "projects/${local.project}/databases/(default)/documents/${local.collection_path}/{messageId}"
  }
  depends_on = [google_project_service.translate-ext, google_project_iam_member.translate-text-account]
}
