# Deploy from Kubeadm


## Init
kubeadm init --apiserver-advertise-address=10.0.1.10 --pod-network-cidr=10.100.0.0/16 --node-name=master --service-cidr=172.16.0.0/16


## Install Pod Network (Weavenet)
curl -LO https://reweave.azurewebsites.net/k8s/v1.31/net.yaml -o /opt/src/weave-net.yaml

manually add to daemonset envs:
            - name: IPALLOC_RANGE
              value: 10.0.0.0/16

kubectl apply -f /opt/src/weave-net.yaml

## Worker Nodes to join Cluster:

kubeadm join 10.0.1.10:6443 --token dg9k9k.940ql67t8xpldv0b \
	--discovery-token-ca-cert-hash sha256:3c680251865eb40bb44308a94e7cc0d7b39b9f370a53da40b93bf434e40eb015 \
  --node-name=worker1

kubeadm join 10.0.1.10:6443 --token dg9k9k.940ql67t8xpldv0b \
	--discovery-token-ca-cert-hash sha256:3c680251865eb40bb44308a94e7cc0d7b39b9f370a53da40b93bf434e40eb015 \
  --node-name=worker2

