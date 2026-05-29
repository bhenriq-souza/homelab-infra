terraform {
  backend "gcs" {
    bucket = "homelab-492918-tf-state"
    prefix = "clusters/homelab/prd"
  }
}
