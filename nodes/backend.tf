terraform {
  backend "s3" {
    bucket = "memoryarchivezy"
    key    = "k8sfromscratch/resources.tfstate"
    region = "ap-southeast-1"
  }
}