.PHONY: init plan apply destroy connect

##############
# Node Setup #
##############

init:
	terraform init && terraform validate && terraform fmt
	
plan: 	
	terraform plan -var-file=vars/k8s.json

apply: 
	terraform apply -var-file=vars/k8s.json -auto-approve

destroy: 
	terraform destroy -var-file=vars/k8s.json -auto-approve

connect:
	aws ssm start-session \
	--region ap-southeast-1 \
	--target $$(aws ec2 describe-instances --filters "Name=instance-state-code,Values=16" "Name=tag:Name,Values=master-node" --region ap-southeast-1 | jq '.Reservations[].Instances[].InstanceId' -r)

###########################
# Container Runtime Setup #
###########################

