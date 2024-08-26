variable "vpc_cidr" {}

variable "public_subnet_cidr" {}

variable "private_subnet_cidr" {}

variable "tags" {
  default = {
    Cluster = "k8s-from-scratch"
  }
}

variable "ssh_ips" {}

variable "ec2_ami_id" {}

variable "ec2_type_master" {}
variable "ec2_type_worker" {}

variable "master_node_private_ip" {}

variable "worker_node_1_private_ip" {}

variable "worker_node_2_private_ip" {}