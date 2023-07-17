#!/usr/bin/env bash

# Add current node in  /etc/hosts
echo "127.0.0.1 $(hostname)" >> /etc/hosts
echo "192.168.1.10 $(hostname)" >> /etc/hosts

# create k3d cluster with 2 master nodes and 2 worker nodes
# add loadbalancer for 80 and 443 ports
# configure k3d cluster with calico insted of default flannel

curl -fsSL https://k3d.io/v5.0.1/usage/advanced/calico.yaml > calico.yaml
k3d cluster create cluster1 \
--servers 2 --agents 2 \
-p "80:80@loadbalancer" -p "443:443@loadbalancer" \
--k3s-arg '--flannel-backend=none@server:*' \
--volume "$(pwd)/calico.yaml:/var/lib/rancher/k3s/server/manifests/calico.yaml" \
--volume "/root/scripts:/root/scripts"

# Put the kubeconfig in place, so kubectl can work without params
mkdir -p /root/.kube && \
k3d kubeconfig get cluster1 > /root/.kube/config
mkdir -p /home/vagrant/.kube && \
k3d kubeconfig get cluster1 > /home/vagrant/.kube/config && \
chown -R vagrant:vagrant /home/vagrant/.kube

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubectl bash-completion

kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
chmod a+r /etc/bash_completion.d/kubectl

echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
source ~/.bashrc

# configure kubectx
git clone https://github.com/ahmetb/kubectx /opt/kubectx
ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# Install OLM
kubectl apply -f https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.17.0/crds.yaml
kubectl apply -f https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.17.0/olm.yaml

# Basic package installation
apt update
apt install -y vim dos2unix
cat << EOF > /root/.vimrc
set nomodeline
set bg=dark
set tabstop=2
set expandtab
set ruler
set nu
syntax on
EOF

# Prepare SSH inter-VM communication
mv /home/vagrant/ssh/* /home/vagrant/.ssh
rm -r /home/vagrant/ssh
dos2unix /home/vagrant/.ssh/tmpkey
dos2unix /home/vagrant/.ssh/tmpkey.pub
cat /home/vagrant/.ssh/tmpkey.pub >> /home/vagrant/.ssh/authorized_keys
cat << EOF >> /home/vagrant/.ssh/config
Host k3d*
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF
chown vagrant. /home/vagrant/.ssh/config
chmod 600 /home/vagrant/.ssh/config /home/vagrant/.ssh/tmpkey