# Build a Kubernetes Cluster

a Makefile to record actions

## Design

### Version
1.31

### Container Runtime
CRI: containerd (nodes/loadcri.sh)

### Nodes
3 AWS EC2 instances; Nodes should be in the same network with Internet access; master node can ssh into worker node

- Network: VPC (10.0.2.0/24)
- Master node: controlplane (10.0.2.11)
  - etcd
  - kube-apiserver
  - kube-scheduler
  - kube-controller-manager
  - kubelet
  - kubectl
- Worker node: nodealpha (10.0.2.12)
  - kubelet
  - kube-proxy (as ds)
- Worker node: nodebeta (10.0.2.13)
  - kubelet
  - kube-proxy (as ds)

### Control Plane

### Networking
- Cilium as CNI
- Cilium Ingress Controller? explore

### Security
- kubeconfig
- RBAC: admin role

### Storage


## Deploy

### Setup Nodes and Container Runtime for nodes
- Directory: ./nodes

- command to provision the nodes: 
  ```
  make apply
  ```

- command to bring down the nodes:
  ```
  make destroy
  ```

- command to connect to master-node:
  ```
  make connect
  ```

### Check Container Runtime Setup
- Connect to master-node:
  ```
  make connect
  sudo su
  ```

- Check containerd status:
  ```
  systemctl status containerd
  ```

### Control Plane Setup
- Setup kubelet:
  ```
  curl -LO https://dl.k8s.io/release/v1.31.0/bin/linux/arm64/kubelet && \
  chmod +x kubelet && \
  mv kubelet /usr/local/bin/
  ```

- Setup kubectl:
  ```
  curl -LO https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl
  chmod +x kubectl
  mv kubectl /usr/local/bin/
  ```