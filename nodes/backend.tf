terraform {
  backend "s3" {
    bucket = "memoryarchivezy"
    key    = "k8sfromscratch"
    region = "ap-southeast-1"
  }
}