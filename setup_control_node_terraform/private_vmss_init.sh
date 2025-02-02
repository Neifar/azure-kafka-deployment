#!/bin/bash

sudo sed -i "/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf

wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

sudo apt update
sudo apt install python3-venv -y

mkdir ansible-venv
python3 -m venv ansible-venv/
source ansible-venv/bin/activate

python3 -m pip install ansible
ansible-galaxy collection install azure.azcollection --force
python3 -m pip install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements.txt

ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa <<< y

token=`curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -H Metadata:true | cut -d '"' -f 4`
mysecret=`curl 'https://control-keyvault.vault.azure.net/secrets/github-token?api-version=7.4' -H "Authorization: Bearer $token" | cut -d '"' -f 4`
git clone https://Neifar:$mysecret@github.com/Neifar/azure-kafka-deployment.git

echo "Initialization done"

#/var/lib/waagent/custom-script/download/0