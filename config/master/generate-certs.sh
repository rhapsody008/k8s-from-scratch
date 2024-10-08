#!/bin/sh

# Prepare paths for certs
mkdir -p /etc/kubernetes/pki
mkdir -p /etc/kubernetes/pki/etcd
cd /etc/kubernetes/pki

cat > openssl.cnf << EOF
[ req ]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[ req_distinguished_name ]

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth
EOF

# Kubernetes CA
echo "Generating certificates for Kubernetes CA..."
openssl genrsa -out ca.key 2048
openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr
openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt

# Etcd CA
echo "Generating certificates for Etcd CA..."
openssl genrsa -out etcd/ca.key 2048
openssl req -new -key etcd/ca.key -subj "/CN=ETCD-CA" -out etcd/ca.csr
openssl x509 -req -in etcd/ca.csr -signkey etcd/ca.key -out etcd/ca.crt

# Front proxy CA
echo "Generating certificates for Front proxy CA..."
openssl genrsa -out front-proxy-ca.key 2048
openssl req -new -key front-proxy-ca.key -subj "/CN=FRONT-PROXY-CA" -out front-proxy-ca.csr
openssl x509 -req -in front-proxy-ca.csr -signkey front-proxy-ca.key -out front-proxy-ca.crt

# Kubernetes admin user
echo "Generating certificates for Kubernetes admin user..."
openssl genrsa -out admin.key 2048
openssl req -new -key admin.key -subj "/CN=kube-admin/O=system:masters" -out admin.csr
openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -out admin.crt

# Service account
echo "Generating certificates for service account..."
openssl genrsa -out sa.key 2048
openssl req -new -key sa.key -subj "/CN=serviceaccount/O=system:masters" -out sa.csr
openssl x509 -req -in sa.csr -CA ca.crt -CAkey ca.key -out sa.pub

# Front proxy
echo "Generating certificates for front-proxy-client..."
openssl genrsa -out front-proxy-client.key 2048
openssl req -new -key front-proxy-client.key -subj "/CN=front-proxy-client" -out front-proxy-client.csr
openssl x509 -req -in front-proxy-client.csr -CA front-proxy-ca.crt -CAkey front-proxy-ca.key -out front-proxy-client.crt

# kube-scheduler
echo "Generating certificates for kube-scheduler..."
openssl genrsa -out scheduler.key 2048
openssl req -new -key scheduler.key -subj "/CN=system:kube-scheduler" -out scheduler.csr
openssl x509 -req -in scheduler.csr -CA ca.crt -CAkey ca.key -out scheduler.crt

# kube-controller-manager
echo "Generating certificates for kube-controller-manager..."
openssl genrsa -out controller-manager.key 2048
openssl req -new -key controller-manager.key -subj "/CN=system:kube-controller-manager" -out controller-manager.csr
openssl x509 -req -in controller-manager.csr -CA ca.crt -CAkey ca.key -out controller-manager.crt

# kube-proxy
echo "Generating certificates for kube-proxy..."
openssl genrsa -out kube-proxy.key 2048
openssl req -new -key kube-proxy.key -subj "/CN=kube-proxy" -out kube-proxy.csr
openssl x509 -req -in kube-proxy.csr -CA ca.crt -CAkey ca.key -out kube-proxy.crt

# kube-apiserver-kubelet-client
echo "Generating certificates for kube-apiserver-kubelet-client..."
openssl genrsa -out apiserver-kubelet-client.key 2048
openssl req -new -key apiserver-kubelet-client.key -subj "/CN=kube-apiserver-kubelet-client/O=system:masters" -out apiserver-kubelet-client.csr 
openssl x509 -req -in apiserver-kubelet-client.csr -CA ca.crt -CAkey ca.key -out apiserver-kubelet-client.crt 

# kube-apiserver-etcd-client
echo "Generating certificates for kube-apiserver-etcd-client..."
openssl genrsa -out apiserver-etcd-client.key 2048
openssl req -new -key apiserver-etcd-client.key -subj "/CN=kube-apiserver-etcd-client" -out apiserver-etcd-client.csr -config openssl.cnf
openssl x509 -req -in apiserver-etcd-client.csr -CA etcd/ca.crt -CAkey etcd/ca.key -out apiserver-etcd-client.crt -extfile openssl.cnf -extensions v3_req

# master-node-kubelet-client
echo "Generating certificates for master-node-kubelet-client..."
openssl genrsa -out master-client.key 2048
openssl req -new -key master-client.key -subj "/CN=system:node:master/O=system:nodes" -out master-client.csr
openssl x509 -req -in master-client.csr -CA ca.crt -CAkey ca.key -out master-client.crt

# worker-node-1-kubelet-client
echo "Generating certificates for worker-node-1-kubelet-client..."
openssl genrsa -out worker1-client.key 2048
openssl req -new -key worker1-client.key -subj "/CN=system:node:worker1/O=system:nodes" -out worker1-client.csr
openssl x509 -req -in worker1-client.csr -CA ca.crt -CAkey ca.key -out worker1-client.crt

# worker-node-2-kubelet-client
echo "Generating certificates for worker-node-2-kubelet-client..."
openssl genrsa -out worker2-client.key 2048
openssl req -new -key worker2-client.key -subj "/CN=system:node:worker2/O=system:nodes" -out worker2-client.csr
openssl x509 -req -in worker2-client.csr -CA ca.crt -CAkey ca.key -out worker2-client.crt

# etcd server
cat > etcd/etcd-server-openssl.cnf << EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[req_distinguished_name]

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth,clientAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = master
DNS.2 = localhost
IP.1 = 127.0.0.1
IP.2 = 0:0:0:0:0:0:0:1
EOF
echo "Generating certificates for etcd server..."
openssl genrsa -out etcd/server.key 2048
openssl req -new -key etcd/server.key -subj "/CN=etcd-server" -out etcd/server.csr -config etcd/etcd-server-openssl.cnf
openssl x509 -req -in etcd/server.csr -CA etcd/ca.crt -CAkey etcd/ca.key -out etcd/server.crt -extfile etcd/etcd-server-openssl.cnf -extensions v3_req

# etcd-peer
echo "Generating certificates for etcd-peer..."
openssl genrsa -out etcd/peer.key 2048
openssl req -new -key etcd/peer.key -subj "/CN=etcd-peer" -out etcd/peer.csr
openssl x509 -req -in etcd/peer.csr -CA etcd/ca.crt -CAkey etcd/ca.key -out etcd/peer.crt

# kube-apiserver
echo "Generating certificates for kube-apiserver..."
cat > apiserver-openssl.cnf << EOF
[ req ]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[ req_distinguished_name ]

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth,clientAuth
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = 172.16.0.1
IP.2 = 127.0.0.1
IP.3 = 10.0.1.10
EOF

openssl genrsa -out apiserver.key 2048
openssl req -new -key apiserver.key -subj "/CN=kube-apiserver" -out apiserver.csr -config apiserver-openssl.cnf
openssl x509 -req -in apiserver.csr -CA ca.crt -CAkey ca.key -out apiserver.crt -extfile apiserver-openssl.cnf -extensions v3_req

# master-node-kubelet
echo "Generating certificates for master-node-kubelet..."
cat > master-node-openssl.cnf << EOF
[ req ]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[ req_distinguished_name ]

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth,clientAuth
subjectAltName = @alt_names

[ alt_names ]
IP.1 = 127.0.0.1
IP.2 = 10.0.1.10
EOF
openssl genrsa -out master.key 2048
openssl req -new -key master.key -subj "/CN=master" -out master.csr -config master-node-openssl.cnf
openssl x509 -req -in master.csr -CA ca.crt -CAkey ca.key -out master.crt -extfile master-node-openssl.cnf -extensions v3_req

# worker-node-1-kubelet
echo "Generating certificates for worker-node-1-kubelet..."
openssl genrsa -out worker1.key 2048
openssl req -new -key worker1.key -subj "/CN=worker1" -out worker1.csr
openssl x509 -req -in worker1.csr -CA ca.crt -CAkey ca.key -out worker1.crt

# worker-node-2-kubelet
echo "Generating certificates for worker-node-2-kubelet..."
openssl genrsa -out worker2.key 2048
openssl req -new -key worker2.key -subj "/CN=worker2" -out worker2.csr
openssl x509 -req -in worker2.csr -CA ca.crt -CAkey ca.key -out worker2.crt

# kube-proxy
echo "Generating certificates for kube-proxy..."
openssl genrsa -out kube-proxy.key 2048
openssl req -new -key kube-proxy.key -subj "/CN=kube-proxy/O=system:node-proxier" -out kube-proxy.csr
openssl x509 -req -in kube-proxy.csr -CA ca.crt -CAkey ca.key -out kube-proxy.crt

# Completion
echo "All certificates generated!"
ls -lrthR /etc/kubernetes/pki