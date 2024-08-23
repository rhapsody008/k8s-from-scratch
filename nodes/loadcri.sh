#!/bin/sh

mkdir -p /opt/src
cd /opt/src

echo 'Downloading CRI resources...'

curl -LO https://github.com/containerd/containerd/releases/download/v1.7.20/containerd-1.7.20-linux-arm64.tar.gz
curl -LO https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
curl -LO https://github.com/opencontainers/runc/releases/download/v1.1.13/runc.arm64
curl -LO https://github.com/containernetworking/plugins/releases/download/v1.5.1/cni-plugins-linux-arm64-v1.5.1.tgz

echo 'Downloaded!'


echo 'Installing containerd...'

tar Czxvf /usr/local /opt/src/containerd-1.7.20-linux-arm64.tar.gz
mv /opt/src/containerd.service /lib/systemd/system/containerd.service

echo 'containerd installed!'


echo 'Installing runc...'

install -m 755 runc.arm64 /usr/local/sbin/runc

echo 'runc installed!'


echo 'Installing cni-plugin...'

mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-arm64-v1.5.1.tgz

echo 'cni-plugin installed!'


echo 'Starting containerd...'

systemctl daemon-reload
systemctl enable --now containerd

echo 'containerd started!'