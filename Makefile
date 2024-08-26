###############
# Environment #
###############

KEY_DIR=nodes/keys
KEY_NAME=k8s-from-scratch
MASTER_KEY_NAME=master-worker-comm
SCRIPT_DIR=nodes/scripts
REPO_DIR=/Users/rhapsody/gitrepo/k8s-from-scratch
NODE_HOME_DIR=/home/ubuntu
CONFIG_DIR=config

##############
# Node Setup #
##############
.PHONY: startup cleanup init plan apply destroy connect keygen master-worker-comm master-post-terraform-setup

# One-For-All command for nodes setup
startup: init apply master-post-terraform-setup

# One-For-All command for nodes cleanup
cleanup: destroy
	rm -rf $(REPO_DIR)/$(KEY_DIR)
	rm -f $(REPO_DIR)/$(SCRIPT_DIR)/worker-bootstrap.sh
	rm -rf $(REPO_DIR)/nodes/.terraform
	rm -f $(REPO_DIR)/nodes/.terraform.lock.hcl
	rm -rf $(REPO_DIR)/tmp

init:
	terraform -chdir=$(REPO_DIR)/nodes init
	terraform -chdir=$(REPO_DIR)/nodes fmt
	
plan: keygen master-worker-comm

	terraform -chdir=$(REPO_DIR)/nodes validate
	terraform -chdir=$(REPO_DIR)/nodes plan -var-file=vars/k8s.json

apply: keygen master-worker-comm
	terraform -chdir=$(REPO_DIR)/nodes validate
	terraform -chdir=$(REPO_DIR)/nodes apply -var-file=vars/k8s.json -auto-approve
# Output Master Node Public IP
	mkdir -p $(REPO_DIR)/tmp
	aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=master-node" "Name=instance-state-name,Values=running" \
    --query "Reservations[*].Instances[*].PublicIpAddress" \
	--output text > $(REPO_DIR)/tmp/master_ip

destroy: 
	terraform -chdir=$(REPO_DIR)/nodes destroy -var-file=vars/k8s.json -auto-approve

connect:	
	ssh -i $(REPO_DIR)/$(KEY_DIR)/$(KEY_NAME) ubuntu@$$(cat $(REPO_DIR)/tmp/master_ip)

keygen:
	chmod +x $(REPO_DIR)/$(SCRIPT_DIR)/generate-keys.sh
	REPO_DIR=$(REPO_DIR) \
	KEY_DIR=$(KEY_DIR) \
	KEY_NAME=$(KEY_NAME) \
	MASTER_KEY_NAME=$(MASTER_KEY_NAME) \
	$(REPO_DIR)/$(SCRIPT_DIR)/generate-keys.sh

master-worker-comm:
# Create bootstrap scripts for worker nodes
	echo "preparing bootstrap scripts..."
	cp $(REPO_DIR)/$(SCRIPT_DIR)/master-bootstrap.sh $(REPO_DIR)/$(SCRIPT_DIR)/worker-bootstrap.sh
	cat $(REPO_DIR)/$(KEY_DIR)/$(MASTER_KEY_NAME).pub > /tmp/key
# add master-worker-comm public key to worker nodes to allow master->worker SSH
	echo "\n\necho '\n$$(cat /tmp/key)' >> /home/ubuntu/.ssh/authorized_keys" >> $(REPO_DIR)/$(SCRIPT_DIR)/worker-bootstrap.sh
	echo "boostrap scripts bootstrap complete!"

master-post-terraform-setup:
	chmod +x $(REPO_DIR)/$(SCRIPT_DIR)/master-ssh-setup.sh
	REPO_DIR=$(REPO_DIR) \
	KEY_DIR=$(KEY_DIR) \
	KEY_NAME=$(KEY_NAME) \
	MASTER_KEY_NAME=$(MASTER_KEY_NAME) \
	NODE_HOME_DIR=$(NODE_HOME_DIR) \
	$(REPO_DIR)/$(SCRIPT_DIR)/master-ssh-setup.sh

####################
# Node Preparation #
####################
.PHONY: 

prep-files:
	scp -i $(REPO_DIR)/$(KEY_DIR)/$(KEY_NAME) -r $(REPO_DIR)/$(CONFIG_DIR) ubuntu@$$(cat $(REPO_DIR)/tmp/master_ip):/opt
