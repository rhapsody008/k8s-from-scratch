#!/bin/sh

mkdir -p $REPO_DIR/$KEY_DIR

export SSH_KEY="$REPO_DIR/$KEY_DIR/$KEY_NAME"
export MASTER_WORKER_KEY="$REPO_DIR/$KEY_DIR/$MASTER_KEY_NAME"

if [ -f $KEY_FULL.pub ]; then \
	chmod 0400 $SSH_KEY; \
	echo "Key already exists, skipping..."; \
else \
	ssh-keygen -t rsa -b 2048 -f $SSH_KEY -N ""; \
	chmod 0400 $SSH_KEY $SSH_KEY.pub; \
	echo "New key pair generated: $SSH_KEY"; \
fi

if [ -f $MASTER_WORKER_KEY.pub ]; then \
	chmod 0400 $MASTER_WORKER_KEY; \
	echo "master-worker key already exists, skipping..."; \
else \
	ssh-keygen -t rsa -b 2048 -f $MASTER_WORKER_KEY -C "yizhou0514@gmail.com" -N ""; \
	chmod 0400 $MASTER_WORKER_KEY $MASTER_WORKER_KEY.pub; \
	echo "New master-worker key pair generated: $MASTER_WORKER_KEY"; \
fi
