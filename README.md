# Build a Kubernetes Cluster

a Makefile to record actions

## Design

### Version: 1.31
https://kubernetes.io/releases/download/

### Container Runtime Interface: containerd
CRI: containerd with runc and cni-plugin
https://github.com/containerd/containerd/blob/main/docs/getting-started.md

### Nodes and Node Networking
Design:
- 3 AWS EC2 instances (Ubuntu24.04, t4g.nano); 
- Nodes should be in the same network with Internet access; 
- master node can ssh into worker node

Network Information:
- Network: VPC (public_subnet: 10.0.1.0/24, private_subnet: 10.0.2.0/24)
- Master node: controlplane (10.0.1.10)
  - etcd (:2379)
  - kube-apiserver (:6443)
  - kube-scheduler (:10259)
  - kube-controller-manager (:10257)
  - kubelet (:10250)
  - kubectl
- Worker node: worker-node-1 (10.0.2.11)
  - kubelet (:10250)
  - kube-proxy (as ds) (:10256)
- Worker node: worker-node-2 (10.0.2.12)
  - kubelet (:10250)
  - kube-proxy (as ds) (:10256)


### Control Plane

### K8s Cluster Networking
- Pod IP Range: 192.168.0.0/16 
- Service IP Range: 172.16.0.0/16
- clusterDNS: 172.16.0.10
- kube-apiserver: 172.16.0.1

- Cilium as CNI
- Cilium Ingress Controller? explore

### Security
- kubeconfig
- RBAC: admin role

### Storage


## Deploy

### Startup Nodes and Container Runtime for nodes
- Directory: ./nodes

- command to start up and setup container runtime on nodes: 
  ```
  make startup
  ```

- command to bring down the nodes:
  ```
  make cleanup
  ```

- command to connect to master-node:
  ```
  make connect
  ```

### Check Container Runtime Setup
The container runtime has been setup via EC2 user data in [nodes/master-bootstrap.sh](nodes/master-bootstrap.sh)
1. Connect to master-node and use root:
  ```
  make connect
  sudo su
  ```
**!!The following commands are run inside master-node**
2. Check containerd status:
  ```
  systemctl status containerd
  ```

### Prepare Nodes K8s Components;
1. Prepare directory and copy files into master node:
  ```
  make prep-files
  ```

2. Prepare Certificates: 
No Makefile step created as this is designed to be run on root
Docs: [docs/Certificate.md](docs/Certificate.md)
- Connect to master-node and use root
  ```
  make connect
  sudo su
  ```
  
- Execute cert generation scripts:
  ```
  cd /opt/config/master-scripts
  chmod +x generate-certs.sh
  ./generate-certs.sh
  ```

### Node Kubelet Setup:
2. Setup kubelet:
  ```
  curl -LO https://dl.k8s.io/release/v1.31.0/bin/linux/arm64/kubelet && \
  chmod +x kubelet && \
  mv kubelet /usr/local/bin/
  ```
3. Configure kubelet:
  ```
  mkdir -p /var/lib/kubernetes

  ```
4. Setup kubectl:
  ```
  curl -LO https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl
  chmod +x kubectl
  mv kubectl /usr/local/bin/
  ```

