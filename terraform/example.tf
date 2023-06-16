locals {
  location = "us-central1"
}

resource "google_project" "default" {
  provider        = google-beta.no_user_project_override
  name            = "<PROJECT_NAME>"
  project_id      = "PROJECT_ID"
  billing_account = "<BILLING_ACCOUNT_ID>"
  folder_id       = "1095975223327" # firebase-teams
  labels = {
    "firebase" = "enabled"
  }
}

resource "google_project_service" "service-usage" {
  provider           = google-beta.no_user_project_override
  project            = google_project.default.project_id
  service            = "serviceusage.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "firestore" {
  provider           = google-beta
  project            = google_project.default.project_id
  service            = "firestore.googleapis.com"
  disable_on_destroy = false
  depends_on         = [google_project_service.service-usage]
}

resource "google_firestore_database" "default" {
  project     = google_project.default.project_id
  name        = "(default)"
  location_id = "nam5"  # Note: Firestore uses different location names than functions/extensions
  type        = "FIRESTORE_NATIVE"
  depends_on  = [google_project_service.firestore]
}

terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.0.0"
    }
  }
}
provider "google-beta" {
  alias                 = "no_user_project_override"
  user_project_override = false
}

provider "google-beta" {
  user_project_override = true
}
