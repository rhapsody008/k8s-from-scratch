KEY_DIR=keys
KEY_NAME=k8s-from-scratch

.PHONY: init plan apply destroy connect

##############
# Node Setup #
##############

init:
	terraform init && terraform validate && terraform fmt
	
plan: keygen
	terraform plan -var-file=vars/k8s.json

apply: keygen
	terraform apply -var-file=vars/k8s.json -auto-approve

destroy: 
	terraform destroy -var-file=vars/k8s.json -auto-approve

connect:
	aws ssm start-session \
	--region ap-southeast-1 \
	--target $$(aws ec2 describe-instances --filters "Name=instance-state-code,Values=16" "Name=tag:Name,Values=master-node" --region ap-southeast-1 | jq '.Reservations[].Instances[].InstanceId' -r)

keygen:
	@if [ -f $(KEY_DIR)/$(KEY_NAME).pub ]; then \
		echo "Key already exists, skipping..."; \
	else \
		mkdir -p $(KEY_DIR); \
		ssh-keygen -t rsa -b 2048 -f $(KEY_DIR)/$(KEY_NAME) -N ""; \
		echo "New key pair generated: $(KEY_DIR)/$(KEY_NAME)"; \
	fi


###########################
# Container Runtime Setup #
###########################

