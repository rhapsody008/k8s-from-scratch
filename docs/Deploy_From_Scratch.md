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

Execute cert generation scripts:
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
  cp /opt/config/master/kubelet.service /lib/systemd/system
  ```

### Start kubelet service:
  ```
  systemctl daemon-reload
  systemctl enable --now kubelet
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

## Kube-proxy setup
  ```
  mkdir -p /opt/src/k8s
  cp /opt/config/master/kube-proxy.conf /etc/kubernetes
  cp /opt/config/master/kube-proxy.yaml /opt/src/k8s
  kubectl apply -f /opt/src/k8s/kube-proxy.yaml
  ```

## CoreDNS setup

## CNI setup

## Worker Nodes setup

### prepare files on Master Node
  ```
  chmod +x /opt/config/master/prep-worker-files.sh
  /opt/config/master/prep-worker-files.sh
  ```

3. connect to worker1 
  ```
  exit 
  goworker1
  sudo su
  ```

4. set perms and copy files to correct locations
  ```
  chown root:root /opt/cni/bin
  cp /opt/config/worker1/worker1* /etc/kubernetes/pki
  cp /opt/config/worker1/ca.crt /etc/kubernetes/pki
  cp /opt/config/worker1/kubelet.conf /etc/kubernetes
  cp /opt/config/worker1/kubelet-config.yaml /var/lib/kubernetes
  cp /opt/config/worker1/kubelet.service /lib/systemd/system
  cp /opt/config/worker1/kubelet /usr/local/bin
  ```

5. Start kubelet service:
  ```
  systemctl daemon-reload
  systemctl enable --now kubelet
  ```

6. exit to master node and connect to worker 2:
  ```
  exit 
  goworker2
  sudo su
  ```

7. set perms and copy files to correct locations
  ```
  chown root:root /opt/cni/bin
  cp /opt/config/worker2/worker2* /etc/kubernetes/pki
  cp /opt/config/worker2/ca.crt /etc/kubernetes/pki
  cp /opt/config/worker2/kubelet.conf /etc/kubernetes
  cp /opt/config/worker2/kubelet-config.yaml /var/lib/kubernetes
  cp /opt/config/worker2/kubelet.service /lib/systemd/system
  cp /opt/config/worker2/kubelet /usr/local/bin
  ```

8. Start kubelet service:
  ```
  systemctl daemon-reload
  systemctl enable --now kubelet
  ```



<!-- ### Cilium setup

1. Install cilium-cli
```
cd /opt/src
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=arm64
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
```

2. Install Helm
```
cd /opt/src
curl -LO https://get.helm.sh/helm-v3.15.4-linux-arm64.tar.gz
tar -xzvf helm-v3.15.4-linux-arm64.tar.gz
cp linux-arm64/helm /usr/local/bin
```

3. Install cilium
```
helm repo add cilium https://helm.cilium.io/
chown root:root /opt/cni/bin
helm install cilium cilium/cilium --namespace kube-system --set kubeProxyReplacement=true --set k8sServiceHost=10.0.0.10 --set k8sServicePort=6443 -->



