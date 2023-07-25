# vagrant-k3d

Esse tutorial é baseado no repositório https://github.com/andreyhristov/k3d-vagrant

Só que diferente das instruções do repositório original, vamos fazer o deploy:

- usando debian 11 em vez do ubuntu 20.04
- sem o openconnect
- cluster k8s com 3 master nodes e 2 worker nodes
- acesso ssh também por senha com usuário vagrant
- kubeadm instalado na VM, caso queira transformar em um master node
