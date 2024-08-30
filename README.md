# Build a Kubernetes Cluster

## Design

### Version: `1.31`
https://kubernetes.io/releases/download/

### Container Runtime: `containerd`
https://github.com/containerd/containerd/blob/main/docs/getting-started.md

### Nodes
- 3 AWS `EC2 instances` (Ubuntu24.04, t4g.small(master), t4g.micro(worker)); 
- Nodes should be in the same network with Internet access; 
- master node can ssh into worker node

### Host Network Design
- Network: AWS VPC (cidr: 10.0.0.0/16, public_subnet: 10.0.1.0/24)
- Master node: `controlplane` (10.0.1.10)
  - `kubelet` (:10250)
  - `etcd` (:2379)
  - `kube-apiserver` (:6443)
  - `kube-scheduler` (:10259)
  - `kube-controller-manager` (:10257)
  - `kube-proxy` as DaemonSet
  - `coredns` as kube-dns clusterIP
- Worker node: worker-node-1 (10.0.1.11)
  - `kubelet` (:10250)
  - `kube-proxy` (as DaemonSet)
- Worker node: worker-node-2 (10.0.1.12)
  - `kubelet` (:10250)
  - `kube-proxy` (as DaemonSet)

### Cluster Network Design
- Pod IP Range: `10.100.0.0/16`
- Service IP Range: `172.16.0.0/16`
- clusterDNS: `172.16.0.10`
- kube-apiserver: `172.16.0.1`

### CNI: weave-net
https://github.com/rajch/weave?tab=readme-ov-file#weave-net

### Ingress & Ingress controller
- Under exploration, could be Nginx

## Getting Started

### Startup Nodes and Container Runtime
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

### Prepare Nodes K8s Components
1. Copy files
```
make prep-files
```

2. Connect to master-node and use root:
```
make connect
sudo su
```

**All Steps below are executed in Nodes**

### Option 1: Deploy using Kubeadm
Follow [docs/Deploy_From_Kubeadm.md](docs/Deploy_From_Kubeadm.md)

### Option 2: Deploy everything from scratch
Follow [docs/Deploy_From_Scratch.md](docs/Deploy_From_Scratch.md)

### Test Deployment
1. Start a deployment and create a service:
```
kubectl create deploy nginx --image=nginx --replicas=6
kubectl expose deploy nginx --port=8080 --target-port=80
```

2. Start a pod 
```
kubectl run busybox --image=busybox -- sleep 3600
```

3. Check endpoints, IP ranges, services, DNS, etc.
```
kubectl get po -A -o wide
kubectl get svc -A -o wide
kubectl get endpoints -A -o wide
```

4. Check cluster.local DNS
```
kubectl exec -ti busybox -- nslookup nginx
kubectl exec -ti busybox -- nslookup kubernetes
kubectl exec -ti busybox -- nslookup kube-dns.kube-system.svc.cluster.local
```

## Appendix
### Check raw apis
```
curl --cert /etc/kubernetes/pki/admin.crt --key /etc/kubernetes/pki/admin.key --cacert /etc/kubernetes/pki/ca.crt https://127.0.0.1:6443
```