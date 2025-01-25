#!/bin/env bash

echo "Threathunting Workstation - Installer"
echo "By Roger C.B. Johnsen - www.predefender.com"
echo ""

# Ask for password for admin user on OpenSearch
read -s -p "Enter new OpenSearch Admin password: " pass

# Ensure Alma is fully updated
dnf update -y
dnf install -y epel-release

# Install Ansible
dnf install ansible -y

# Install requirements for Ansible installation script
ansible-galaxy collection install ansible.posix

# Obtain installation files
curl https://raw.githubusercontent.com/rjohnsen/threathunting-workstation/main/setup-ansible.yml -o setup-ansible.yml
curl https://raw.githubusercontent.com/rjohnsen/threathunting-workstation/main/hosts.ini -o hosts.ini
curl https://raw.githubusercontent.com/rjohnsen/threathunting-workstation/main/docker-compose.yml -o docker-compose.yml

# Set password for OpenSearch
sed -i "s/REPLACEME/$pass/g" docker-compose.yml

# Run Ansible playbook
ansible-playbook -c hosts.ini setup-ansible.yml
