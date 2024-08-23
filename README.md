# Build a Kubernetes Cluster

a Makefile to record sequence of Actions

## Design

### Version
1.31

### Nodes
Stack of Docker containers within a Docker-compose file; Nodes should be in the same network with Internet access; containers can ssh into each other
- Network: k8s-network (172.18.0.0/16)
- Master node: controlplane (172.18.0.2)
  - etcd
  - kube-apiserver
  - kube-scheduler
  - kube-controller-manager
  - kubelet
  - kubectl
- Worker node: nodealpha (172.18.0.3)
  - kubelet
  - kube-proxy (as ds)
- Worker node: nodebeta (172.18.0.4)
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

### Setup Docker container environment for nodes
- Directory: ./node-setup
- command to start the nodes: 
  ```
  make start
  ```
- command to bring down the nodes:
  ```
  make clean
  ```
- command to generate ssh keys for controlplane: