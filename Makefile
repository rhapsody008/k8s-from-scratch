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

download-cri:
	mkdir -p /opt/src && \
    cd /opt/src && \
    curl -LO https://github.com/containerd/containerd/releases/download/v1.7.20/containerd-1.7.20-linux-arm64.tar.gz && \
  	curl -LO https://raw.githubusercontent.com/containerd/containerd/main/containerd.service && \
  	curl -LO https://github.com/opencontainers/runc/releases/download/v1.1.13/runc.arm64 && \
  	curl -LO https://github.com/containernetworking/plugins/releases/download/v1.5.1/cni-plugins-linux-arm64-v1.5.1.tgz

install-cri:
	cd /opt/src && \
  	tar Czxvf /usr/local containerd-1.7.20-linux-arm64.tar.gz && \
  	mv containerd.service /lib/systemd/system/containerd.service && \
  	install -m 755 runc.arm64 /usr/local/sbin/runc && \
  	mkdir -p /opt/cni/bin && \
  	tar Cxzvf /opt/cni/bin cni-plugins-linux-arm64-v1.5.1.tgz

load-cri:
	systemctl daemon-reload
	systemctl enable --now containerd