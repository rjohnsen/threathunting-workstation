#!/bin/env bash

read -s -p "Enter new OpenSearch Admin password: " pass

dnf update -y
dnf install -y epel-release
dnf install ansible -y

curl https://raw.githubusercontent.com/rjohnsen/threathunting-workstation/main/setup.yml -o setup.yml
curl https://raw.githubusercontent.com/rjohnsen/threathunting-workstation/main/hosts.ini -o hosts.ini
curl https://raw.githubusercontent.com/rjohnsen/threathunting-workstation/main/docker-compose.yml -o docker-compose.yml

sed -i "s/REPLACEME/$pass/g" docker-compose.yml

setenforcee 0
ansible-playbook -c hosts.ini setup.yml
setenforce 1
