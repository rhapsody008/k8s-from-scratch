#!/bin/sh

export SSH_KEY="/home/ubuntu/.ssh/master-worker-comm"

# Create directories
ssh -o StrictHostKeyChecking=accept-new -i $SSH_KEY ubuntu@10.0.1.11 sudo mkdir -p /opt/config /etc/kubernetes/pki
ssh -o StrictHostKeyChecking=accept-new -i $SSH_KEY ubuntu@10.0.1.12 sudo mkdir -p /opt/config /etc/kubernetes/pki

# Prepare files
cp /etc/kubernetes/pki/ca.crt /opt/config/worker1/
cp /etc/kubernetes/pki/worker1* /opt/config/worker1/
cp /etc/kubernetes/pki/ca.crt /opt/config/worker2/
cp /etc/kubernetes/pki/worker2* /opt/config/worker2/

# Copy files to worker1
scp -i $SSH_KEY -r /opt/config/worker1 ubuntu@10.0.1.11:/opt/config

# Copy files to worker2
scp -i $SSH_KEY -r /opt/config/worker2 ubuntu@10.0.1.12:/opt/config
