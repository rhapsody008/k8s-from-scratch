# Define the container names
COMPOSE_FILE = ./node-setup/docker-compose.yaml
PROJECT_NAME = k8s-cluster

# SSH key filenames
SSH_KEY = controlplane_ssh_key

.PHONY: start all build up down clean generate-ssh-key

# Start the cluster
start: build up generate-ssh-key

# Build the Docker images specified in the docker-compose.yml file
build:
	docker-compose -f $(COMPOSE_FILE) build

# Bring up the containers
up:
	docker-compose -f $(COMPOSE_FILE) --project-name $(PROJECT_NAME) up -d

# Bring down the containers
down:
	docker-compose -f $(COMPOSE_FILE) --project-name $(PROJECT_NAME) down

# Clean up all containers and networks
clean: down
	docker-compose -f $(COMPOSE_FILE) --project-name $(PROJECT_NAME) rm -f
	docker network prune -f

# Generate SSH keys for the nodes
generate-ssh-key:
	@if [ ! -f $(SSH_KEY) ]; then \
		ssh-keygen -t rsa -f $(SSH_KEY) -N ""; \
		echo "SSH keys generated."; \
	else \
		echo "SSH keys already exist."; \
	fi
