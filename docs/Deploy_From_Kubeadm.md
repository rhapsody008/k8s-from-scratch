# Deploy from Kubeadm

## Init
```
kubeadm init --apiserver-advertise-address=10.0.1.10 --pod-network-cidr=10.100.0.0/16 --node-name=master --service-cidr=172.16.0.0/16
```

### Configure user creds
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Copy join token
Format:
```
kubeadm join 10.0.1.10:6443 --token cdekia.gryu2uxnc4y3g0iv \
	--discovery-token-ca-cert-hash sha256:392d04b7e272b8cb5e36f15c72cbefd91c2b4210d02e4347eedd9f87d6965efa
```

## Install Pod Network (Weavenet)
```
mkdir -p /opt/src/k8s
cp /opt/config/master/weave-net.yaml /opt/src/k8s
kubectl apply -f /opt/src/k8s/weave-net.yaml
```

## Worker Nodes to join Cluster:
### Login
```
make connect
goworker1
sudo su


make connect
goworker2
sudo su
```

### Join
```
kubeadm join 10.0.1.10:6443 --token cdekia.gryu2uxnc4y3g0iv \
	--discovery-token-ca-cert-hash sha256:392d04b7e272b8cb5e36f15c72cbefd91c2b4210d02e4347eedd9f87d6965efa \
  --node-name=worker1

kubeadm join 10.0.1.10:6443 --token cdekia.gryu2uxnc4y3g0iv \
	--discovery-token-ca-cert-hash sha256:392d04b7e272b8cb5e36f15c72cbefd91c2b4210d02e4347eedd9f87d6965efa \
  --node-name=worker2
```

## Check cluster status 
```
kubectl get nodes
kubectl get po -n kube-system -o wide
```