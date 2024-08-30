# Deploy Everything from Scratch

## Prepare Nodes K8s Components
### Prepare directory and copy files into master node
```
make prep-files
```

### Connect to master-node and use root:
```
make connect
sudo su
```

**All Steps below are executed in Nodes**

### Prepare Certificates
```
chmod +x /opt/config/master/generate-certs.sh
/opt/config/master/generate-certs.sh
```

### Setup admin user kubeconfig
```
mkdir -p /root/.kube /home/ubuntu/.kube
cp /opt/config/master/admin-kubeconfig /root/.kube/config
cp /opt/config/master/admin-kubeconfig /home/ubuntu/.kube/config
```

## Master Node Kubelet Setup:

### Configure kubelet
```
mkdir -p /var/lib/kubernetes
cp /opt/config/master/kubelet.conf /etc/kubernetes
cp /opt/config/master/kubelet-config.yaml /var/lib/kubernetes
cp /opt/config/master/kubelet.service /usr/lib/systemd/system
rm -rf /usr/lib/systemd/system/kubelet.service.d
```

### Start kubelet service:
```
systemctl daemon-reload
systemctl restart kubelet
```

## Control plane setup

### Start `etcd` 
```
cp /opt/config/master/etcd.yaml /etc/kubernetes/manifests/
```

### Check container status
```
nerdctl -n k8s.io ps
```

### Start `kube-apiserver` 
```
cp /opt/config/master/kube-apiserver.yaml /etc/kubernetes/manifests/
```

### Start `kube-controller-manager`
```
cp /opt/config/master/controller-manager.conf /etc/kubernetes
cp /opt/config/master/kube-controller-manager.yaml /etc/kubernetes/manifests
```

### Prepare and start `kube-scheduler`
```
cp /opt/config/master/scheduler.conf /etc/kubernetes
cp /opt/config/master/kube-scheduler.yaml /etc/kubernetes/manifests
```

### Check everything running fine
```
kubectl get po -n kube-system
```

## Add-ons Configuration

### Copy files
```
mkdir -p /opt/src/k8s
cp /opt/config/master/kube-proxy.conf /etc/kubernetes
cp /opt/config/master/kube-proxy.yaml /opt/src/k8s
cp /opt/config/master/coredns.yaml /opt/src/k8s
cp /opt/config/master/weave-net.yaml /opt/src/k8s

```

## Kube-proxy setup
```
kubectl apply -f /opt/src/k8s/kube-proxy.yaml
```

## CoreDNS setup
```
kubectl apply -f /opt/src/k8s/coredns.yaml
```
**CoreDNS won't be ready until CNI has set up.**

## CNI - Weave net setup
```
kubectl apply -f /opt/src/k8s/weave-net.yaml
```

## Worker Nodes setup

### Prepare files on Master Node
```
chmod +x /opt/config/master/prep-worker-files.sh
/opt/config/master/prep-worker-files.sh
```

### Connect to worker1 
Open another terminal:
```
# Connect to master
make connect

# Connect to worker1
goworker1

# On worker 1, work as root
sudo su
```

### Prep files
```
chown root:root /opt/cni/bin
cp /opt/config/worker1/worker1* /etc/kubernetes/pki
cp /opt/config/worker1/ca.crt /etc/kubernetes/pki
cp /opt/config/worker1/kubelet.conf /etc/kubernetes
cp /opt/config/worker1/kubelet-config.yaml /var/lib/kubernetes
cp /opt/config/worker1/kubelet.service /usr/lib/systemd/system
rm -rf /usr/lib/systemd/system/kubelet.service.d
```

### Start worker1 kubelet service:
```
systemctl daemon-reload
systemctl restart kubelet
```

### Connect to worker2
Open another terminal:
```
# Connect to master
make connect

# Connect to worker1
goworker2

# On worker 1, work as root
sudo su
```

### set perms and copy files to correct locations
```
chown root:root /opt/cni/bin
cp /opt/config/worker2/worker2* /etc/kubernetes/pki
cp /opt/config/worker2/ca.crt /etc/kubernetes/pki
cp /opt/config/worker2/kubelet.conf /etc/kubernetes
cp /opt/config/worker2/kubelet-config.yaml /var/lib/kubernetes
cp /opt/config/worker2/kubelet.service /usr/lib/systemd/system
rm -rf /usr/lib/systemd/system/kubelet.service.d
```

### Start kubelet service
```
systemctl daemon-reload
systemctl restart kubelet
```

### Check node registration status on Master Node:
```
kubectl get nodes
```


<!-- ## CNI - Cilium setup

### Install Helm
```
cd /opt/src
curl -LO https://get.helm.sh/helm-v3.15.4-linux-arm64.tar.gz
tar -xzvf helm-v3.15.4-linux-arm64.tar.gz
cp linux-arm64/helm /usr/local/bin
```

### Install cilium
```
helm repo add cilium https://helm.cilium.io/
chown root:root /opt/cni/bin
helm install cilium cilium/cilium --namespace kube-system \
                                  --set kubeProxyReplacement=true \
                                  --set k8sServiceHost=10.0.1.10 \
                                  --set k8sServicePort=6443 \
                                  --set ipam.operator.clusterPoolIPv4PodCIDRList=10.100.0.0/16 \
                                  --set policyEnforcementMode=never \
                                  --set hostPort.enabled=true \
                                  --set nodePort.enabled=true \
                                  --set endpointRoutes.enabled=true
```

### (Optional) Install cilium-cli
```
cd /opt/src
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=arm64
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
```

### Check Cilium status
```
cilium status -n kube-system
``` -->