#!/bin/sh

# Create directories
mkdir -p \
/opt/src \
/opt/cni/bin \
/etc/cni/net.d \
/etc/kubernetes/manifests \
/etc/kubernetes/pki \
/opt/config \
/var/lib/kubernetes \
/var/lib/etcd \
/etc/ssl/certs \
/etc/ca-certificates \
/usr/local/share/ca-certificates \
/usr/share/ca-certificates \
/etc/containerd
chown ubuntu:ubuntu /opt/config
chown root:root /opt/cni/bin
chmod 755 /opt/cni/bin /etc/cni/net.d

# WORK DIR
cd /opt/src

# Download resources
echo 'Downloading CRI resources...'

curl -LO https://github.com/containerd/containerd/releases/download/v1.7.20/containerd-1.7.20-linux-arm64.tar.gz
curl -LO https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
curl -LO https://github.com/opencontainers/runc/releases/download/v1.1.13/runc.arm64
curl -LO https://github.com/containernetworking/plugins/releases/download/v1.5.1/cni-plugins-linux-arm64-v1.5.1.tgz
curl -LO https://github.com/containerd/nerdctl/releases/download/v1.7.6/nerdctl-1.7.6-linux-arm64.tar.gz

echo 'Downloaded!'

# Install resources
echo 'Installing containerd and nerdctl...'
tar Czxvf /usr/local /opt/src/containerd-1.7.20-linux-arm64.tar.gz
tar Cxzvf /usr/local/bin nerdctl-1.7.6-linux-arm64.tar.gz
mv /opt/src/containerd.service /lib/systemd/system/containerd.service

cat << EOF | tee /etc/containerd/config.toml
version = 2
[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
   [plugins."io.containerd.grpc.v1.cri".containerd]
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v2"
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true
EOF

echo 'containerd installed!'


echo 'Installing runc...'
install -m 755 runc.arm64 /usr/local/sbin/runc
echo 'runc installed!'

echo 'Starting containerd...'
systemctl daemon-reload
systemctl enable --now containerd
echo 'containerd started!'

echo 'Installing cni-plugin...'
tar Cxzvf /opt/cni/bin cni-plugins-linux-arm64-v1.5.1.tgz

# CNI_DIR=/opt/cni
# CNI_CONFIG_DIR=/etc/cni/net.d 

# cat << EOF | tee $CNI_CONFIG_DIR/10-containerd-net.conflist
# {
#   "cniVersion": "1.0.0",
#   "name": "containerd-net",
#   "plugins": [
#     {
#       "type": "bridge",
#       "bridge": "cni0",
#       "isGateway": true,
#       "ipMasq": true,
#       "promiscMode": true,
#       "ipam": {
#         "type": "host-local",
#         "ranges": [
#           [{
#             "subnet": "10.100.0.0/16"
#           }]
#         ],
#         "routes": [
#           { "dst": "0.0.0.0/0" },
#           { "dst": "::/0" }
#         ]
#       }
#     },
#     {
#       "type": "portmap",
#       "capabilities": {"portMappings": true}
#     }
#   ]
# }
# EOF

echo 'cni-plugin installed!'

# Enable IP forwarding
sysctl net.ipv4.ip_forward=1
sysctl -p

# prepare packages
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Download kube repo keyring
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl