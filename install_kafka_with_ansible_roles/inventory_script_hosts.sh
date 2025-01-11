#!/bin/bash

myvar=$(az vmss list-instance-public-ips --resource-group test_kafka --name kafka-vmss)
public_dns_names=$(echo $myvar | jq -r '.[].dnsSettings.fqdn')

private_var=$(az vmss nic list -g test_kafka --vmss-name kafka-vmss)
private_ips=$(echo $private_var | jq -r '.[].ipConfigurations[0].privateIPAddress')
counter=0
private_ip_list=($private_ips)
public_dns_list=($public_dns_names)
list_length=${#private_ip_list[@]}

echo "[kafka]"
for ((i = 0; i < ${#private_ip_list[@]}; i++))
do
public_dns="${public_dns_list[i]}"
private_ip="${private_ip_list[i]}"
if [[ "$public_dns" == *"kafka"* ]]; then
    ((counter++))
    echo "$public_dns kafka_broker_id=$counter private_ip=$private_ip"
fi
done


echo "[zookeeper]"
for ((i = 0; i < ${#private_ip_list[@]}; i++))
do
public_dns="${public_dns_list[i]}"
private_ip="${private_ip_list[i]}"
if [[ "$public_dns" == *"zookeeper"* ]]; then
    ((counter++))
    echo "$public_dns private_ip=$private_ip"
fi
done

echo "[all:vars]"
echo "ansible_ssh_private_key_file=~/.ssh/id_rsa"
echo "ansible_user=azureuser"
echo "ansible_python_interpreter=/usr/bin/python3"

