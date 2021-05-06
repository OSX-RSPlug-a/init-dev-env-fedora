#!/bin/bash


if [[ "${UID}" -ne 0 ]]
then
 echo 'Must execute with sudo or root' >&2
 exit 1
fi

# update
sudo dnf update

# install dev env with tag
sudo yum groupinstall 'Development Tools'

sudo yum install curl libxcrypt-compat htop

# install packs
sudo dnf -y install dnf-plugins-core nodejs npm nvm ansible poetry podman buildah python3-dnf-plugin-local nfs-utils snapd

# config snap
sudo ln -s /var/lib/snapd/snap /snap

# install podman-compose
pip3 install https://github.com/containers/podman-compose/archive/devel.tar.gz

# add docker repo
curl https://download.docker.com/linux/fedora/33/x86_64/stable/Packages/docker-ce-20.10.2-3.fc33.x86_64.rpm -o docker-ce.rpm

# install docker
sudo dnf -y install docker-ce.rpm

# vscode repo
curl https://az764295.vo.msecnd.net/stable/d2e414d9e4239a252d1ab117bd7067f125afd80a/code-1.50.1-1602601064.el7.x86_64.rpm -o code.rpm

# install vscode 
sudo dnf install code.rpm

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
    sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo && \
    sudo dnf -y install packer
    
