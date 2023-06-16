# Getting Started with Terraform Module Extensions

[Terraform Modules](https://developer.hashicorp.com/terraform/language/modules) offer a similar capability to Firebase Extensions.  Google already provides a variety of [Modules](https://registry.terraform.io/namespaces/terraform-google-modules), which are offered with significantly more polish than the proof-of-concept Modules provided here. 

Current Proof Of Concept Extensions:
  * [firestore-palm-summarize-text](../firestore-palm-summarize-text/terraform-module/)
  * [firestore-translate-text](../firestore-translate-text/terraform-module/)

## Before you Begin
If you are new to Terraform, you may want to go through the [Firebase Terraform Codelab](https://firebase.google.com/codelabs/firebase-terraform#0) to learn about the basics of using Terraform, and the resources available in Firebase.  

You will need to have a GCP or Firebase Project with Firestore enabled and a Billing Account associated before you can add any of the above extensions.  Your .tf file does not necessarily need to have google_project or google_firestore_database resources, but it will generally be easier to work with if you manage the entire resource set in Terraform.

[example.tf](./example.tf) has a fairly simple terraform configuration you can start from.  Replace the ```<PROJECT_ID> <PROJECT_NAME> <BILLING_ACCOUNT>``` placeholders and run with ```terraform apply``` as usual.

## Installing an Extensions

Extension installing is similar to adding a Terraform Resource, but with the ```module``` syntax instead.  Locally provided modules (like we current have) are added with a block like:

```
module "summarize-module" {
  source   = "./extensions/firestore-palm-summarize-text/terraform-module"
  project  = google_project.default.project_id
  location = "us-central1"
  depends_on = [google_firestore_database.default]
}
```
or
```
module "translate-module" {
  source            = "./extensions/firestore-translate-text/terraform-module"
  project           = google_project.default.project_id
  location          = "us-central1"
  collection_path   = "text-to-translate"
  input_field_name  = "input-text"
  output_field_name = "output-text"
  depends_on        = [google_firestore_database.default]
}
```

Terraform Modules (like Extensions) often have optional parameters, in our examples, only ```project``` and ```location``` are strictly required.

## Non Default Functions Code
If you with so build and upload the cloud-functions implementation yourself, you can compile and deploy the src like so:
```
TODO
```

## Pipelining Extensions
Some Extensions are ameniable to pipelining (outputs from the first are inputs of the second).  The current pipeline approach uses Firestore as a transfer medium, but other options are available if the Cloud Functions are built to support it.  A very simple pipelined extensions example would be to Summarize Text via PaLM, then Translate it to languages you support:

```
module "summarize-module" {
  source   = "./extensions/firestore-palm-summarize-text/terraform-module"
  project  = google_project.default.project_id
  location = local.location
  depends_on = [google_firestore_database.default]
}

module "translate-module" {
  source           = "./extensions/firestore-translate-text/terraform-module"
  pipe = module.summarize-module
  output_field_name = "translated"
}
```

With this approach the project, location, and input/output field pairs are connected by the underlying Module implemention, so you can avoid misconfigurations.