# Define the container names
DOCKER_DIR = ./node-setup
COMPOSE_FILE = docker-compose.yaml
PROJECT_NAME = k8s-cluster

# SSH key filenames
SSH_KEY = controlplane_ssh_key

.PHONY: init plan apply destroy connect

##############
# Node Setup #
##############

init:
	terraform init && \
	terraform validate
	
plan: 	
	terraform -chdir=nodes plan -var-file=vars/k8s.json

apply: 
	terraform -chdir=nodes apply -var-file=vars/k8s.json -auto-approve

destroy: 
	terraform -chdir=nodes destroy -var-file=vars/k8s.json -auto-approve

connect:
aws ssm start-session \
	--region ap-southeast-1 \
	--target $$(aws ec2 describe-instances --filters "Name=instance-state-code,Values=16" "Name=tag:Name,Values=master-node" --region ap-southeast-1 | jq '.Reservations[].Instances[].InstanceId' -r)

###########################
# Container Runtime Setup #
###########################