#!/bin/bash

sudo lvextend -L+10G /dev/rootvg/homelv
sudo xfs_growfs /dev/rootvg/homelv

sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo dnf install terraform -y


curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py --user
pip install --user ansible
ansible-galaxy collection install azure.azcollection --force
pip install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements.txt

ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa <<< y

token=`curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -H Metadata:true | cut -d '"' -f 4`
mysecret=`curl 'https://control-keyvault.vault.azure.net/secrets/github-token?api-version=7.4' -H "Authorization: Bearer $token" | cut -d '"' -f 4`
git clone -b redhat https://Neifar:$mysecret@github.com/Neifar/azure-kafka-deployment.git

echo "Initialization done"

#/var/lib/waagent/custom-script/download/0