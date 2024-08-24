#!/bin/sh

echo "Wait for 2 minutes for EC2 instances bootstrap..."
sleep 120

# Copy master-worker-comm private key to master node to allow master->worker SSH
export MASTER_IP=$(aws ec2 describe-instances \
                --filters "Name=tag:Name,Values=master-node" "Name=instance-state-name,Values=running" \
                --query "Reservations[*].Instances[*].PublicIpAddress" \
                --output text)

export CMD_KEY_CLEANING="if [ -f $NODE_HOME_DIR/.ssh/$MASTER_KEY_NAME ];then rm -f $NODE_HOME_DIR/.ssh/$MASTER_KEY_NAME; fi"

cat /dev/null > ~/.ssh/known_hosts
ssh -o StrictHostKeyChecking=accept-new -i $REPO_DIR/$KEY_DIR/$KEY_NAME ubuntu@$MASTER_IP $CMD_KEY_CLEANING
echo "Removed old keys."
scp -i $REPO_DIR/$KEY_DIR/$KEY_NAME $REPO_DIR/$KEY_DIR/$MASTER_KEY_NAME ubuntu@$MASTER_IP:$NODE_HOME_DIR/.ssh/

# Setup aliases for easy ssh access
cat > $REPO_DIR/tmp/.bash_aliases << EOF
alias goworker1="ssh -o StrictHostKeyChecking=accept-new -i $NODE_HOME_DIR/.ssh/$MASTER_KEY_NAME ubuntu@10.0.2.11"
alias goworker2="ssh -o StrictHostKeyChecking=accept-new -i $NODE_HOME_DIR/.ssh/$MASTER_KEY_NAME ubuntu@10.0.2.12"
EOF
scp -i $REPO_DIR/$KEY_DIR/$KEY_NAME $REPO_DIR/tmp/.bash_aliases ubuntu@$MASTER_IP:$NODE_HOME_DIR/
ssh -i $REPO_DIR/$KEY_DIR/$KEY_NAME ubuntu@$MASTER_IP source $NODE_HOME_DIR/.bashrc
echo "Alias updated!"
