#!/bin/bash


if [[ "${UID}" -ne 0 ]]
then
 echo 'Must execute with sudo or root' >&2
 exit 1
fi

# update
sudo dnf update -y

# install dev env with tag
sudo yum groupinstall 'Development Tools'

# install packs
sudo yum install -y curl libxcrypt-compat htop tilix

# install packs
sudo dnf install -y dnf-plugins-core nodejs npm nvm ansible python3-pip poetry podman buildah python3-dnf-plugin-local nfs-utils snapd

# config snap
sudo ln -s /var/lib/snapd/snap /snap

# install podman-compose
pip3 install https://github.com/containers/podman-compose/archive/devel.tar.gz

# add docker repo
curl https://download.docker.com/linux/fedora/33/x86_64/stable/Packages/docker-ce-20.10.2-3.fc33.x86_64.rpm -o docker-ce.rpm

# install docker
sudo dnf install -y docker-ce.rpm

# vscode repo
curl https://az764295.vo.msecnd.net/stable/d2e414d9e4239a252d1ab117bd7067f125afd80a/code-1.50.1-1602601064.el7.x86_64.rpm -o code.rpm

# install vscode 
sudo dnf install -y code.rpm

# isntall auth tool
sudo snap install authy --beta

# add aws-cli repo
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# unzip it
unzip awscliv2.zip

sudo ./aws/install

rm -rf aws
rm -f awscliv2.zip

eval "$(ssh-agent -s)"

ssh-add ~/.ssh/id_rsa

# install redhat dnf-core and hashcorp packer
sudo dnf install -y dnf-plugins-core && \
    sudo dnf -y config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo && \
    sudo dnf install -y packer \


# k8S install and post config
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet

# config iptables for Docker and K8S
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system


