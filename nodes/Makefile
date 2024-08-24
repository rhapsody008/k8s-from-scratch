KEY_DIR=keys
KEY_NAME=k8s-from-scratch
MASTER_KEY_NAME=master-worker-comm
SCRIPT_DIR=scripts
REPO_DIR=/Users/rhapsody/gitrepo/k8s-from-scratch/nodes
NODE_HOME_DIR=/home/ubuntu

.PHONY: init plan apply destroy connect keygen master-worker-comm master-post-terraform-setup startup cleanup

##############
# Node Setup #
##############

startup: init apply master-post-terraform-setup

cleanup: destroy
	rm -rf keys
	rm -f scripts/worker-bootstrap.sh
	rm -rf .terraform
	rm -f .terraform.lock.hcl

init:
	terraform init && terraform fmt
	
plan: keygen master-worker-comm
	terraform validate
	terraform plan -var-file=vars/k8s.json

apply: keygen master-worker-comm
	terraform validate
	terraform apply -var-file=vars/k8s.json -auto-approve

destroy: 
	terraform destroy -var-file=vars/k8s.json -auto-approve

connect:
	aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=master-node" "Name=instance-state-name,Values=running" \
    --query "Reservations[*].Instances[*].PublicIpAddress" \
	--output text > /tmp/master_ip
	ssh -i $(KEY_DIR)/$(KEY_NAME) ubuntu@$$(cat /tmp/master_ip)

keygen:
	chmod +x $(REPO_DIR)/$(SCRIPT_DIR)/generate-keys.sh
	REPO_DIR=$(REPO_DIR) \
	KEY_DIR=$(KEY_DIR) \
	KEY_NAME=$(KEY_NAME) \
	MASTER_KEY_NAME=$(MASTER_KEY_NAME) \
	$(REPO_DIR)/$(SCRIPT_DIR)/generate-keys.sh

master-worker-comm:
# Create bootstrap scripts for worker nodes
	cp $(SCRIPT_DIR)/master-bootstrap.sh $(SCRIPT_DIR)/worker-bootstrap.sh
	cat $(KEY_DIR)/$(MASTER_KEY_NAME).pub > /tmp/key
# add master-worker-comm public key to worker nodes to allow master->worker SSH
	echo "\n\necho '\n$$(cat /tmp/key)' >> /home/ubuntu/.ssh/authorized_keys" >> $(SCRIPT_DIR)/worker-bootstrap.sh

master-post-terraform-setup:
	chmod +x $(REPO_DIR)/$(SCRIPT_DIR)/master-ssh-setup.sh
	REPO_DIR=$(REPO_DIR) \
	KEY_DIR=$(KEY_DIR) \
	KEY_NAME=$(KEY_NAME) \
	MASTER_KEY_NAME=$(MASTER_KEY_NAME) \
	NODE_HOME_DIR=$(NODE_HOME_DIR) \
	$(REPO_DIR)/$(SCRIPT_DIR)/master-ssh-setup.sh

###########################
# Container Runtime Setup #
###########################
