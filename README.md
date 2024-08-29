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
- Network: VPC (public_subnet: 10.0.0.0/24, private_subnet: 10.0.1.0/24)
- Master node: controlplane (10.0.0.10)
  - etcd (:2379)
  - kube-apiserver (:6443)
  - kube-scheduler (:10259)
  - kube-controller-manager (:10257)
  - kubelet (:10250)
  - kubectl
- Worker node: worker-node-1 (10.0.1.11)
  - kubelet (:10250)
  - kube-proxy (as ds) (:10256)
- Worker node: worker-node-2 (10.0.1.12)
  - kubelet (:10250)
  - kube-proxy (as ds) (:10256)


### Control Plane

### K8s Cluster Networking
- Pod IP Range: 10.100.0.0/16
- Service IP Range: 172.16.0.0/16
- clusterDNS: 172.16.0.10
- kube-apiserver: 172.16.0.1

- Cilium as CNI
- Cilium Ingress Controller? explore

## Startup Nodes and Container Runtime
**Note: Container Runtime and kubeadm/kubelet/kubectl are downloaded in node init scripts [nodes/scripts/master-bootstrap.sh](nodes/scripts/master-bootstrap.sh)**

1. start up and setup container runtime on nodes: 
  ```
  make startup
  ```

2. bring down the nodes:
  ```
  make cleanup
  ```

3. connect to master-node:
  ```
  make connect
  ```

## Deploy using Kubeadm
Please follow [docs/Deploy_From_Kubeadm.md](docs/Deploy_From_Kubeadm.md)

## Deploy everything from scratch
Please follow [docs/Deploy_From_Scratch.md](docs/Deploy_From_Scratch.md)


