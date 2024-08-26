resource "aws_key_pair" "node_key" {
  key_name   = "k8s-from-scratch"
  public_key = file("keys/k8s-from-scratch.pub")
}

resource "aws_instance" "master_node" {
  ami                         = var.ec2_ami_id
  instance_type               = var.ec2_type_master
  subnet_id                   = aws_subnet.k8s_public_subnet.id
  security_groups             = [aws_security_group.master_node_sg.id]
  associate_public_ip_address = true
  private_ip                  = var.master_node_private_ip

  iam_instance_profile = "AmazonSSMRoleForInstancesQuickSetup"
  key_name             = aws_key_pair.node_key.key_name

  tags = {
    Name = "master-node"
  }
  user_data = file("scripts/master-bootstrap.sh")

}

resource "aws_instance" "worker_node_1" {
  ami                         = var.ec2_ami_id
  instance_type               = var.ec2_type_worker
  subnet_id                   = aws_subnet.k8s_private_subnet.id
  security_groups             = [aws_security_group.worker_node_sg.id]
  associate_public_ip_address = false
  private_ip                  = var.worker_node_1_private_ip

  iam_instance_profile = "AmazonSSMRoleForInstancesQuickSetup"
  key_name             = aws_key_pair.node_key.key_name

  tags = {
    Name = "worker-node-1"
  }
  user_data = file("scripts/worker-bootstrap.sh")
}

resource "aws_instance" "worker_node_2" {
  ami                         = var.ec2_ami_id
  instance_type               = var.ec2_type_worker
  subnet_id                   = aws_subnet.k8s_private_subnet.id
  security_groups             = [aws_security_group.worker_node_sg.id]
  associate_public_ip_address = false
  private_ip                  = var.worker_node_2_private_ip

  iam_instance_profile = "AmazonSSMRoleForInstancesQuickSetup"
  key_name             = aws_key_pair.node_key.key_name

  tags = {
    Name = "worker-node-2"
  }
  user_data = file("scripts/worker-bootstrap.sh")
}
