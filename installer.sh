#!/bin/env bash

echo "Threathunting Workstation - Installer"
echo "By Roger C.B. Johnsen - www.predefender.com"
echo ""

# Ensure Alma is fully updated
dnf update -y
dnf install -y epel-release

# Install Ansible and Git
dnf install git ansible -y

# Install requirements for Ansible installation script
ansible-galaxy collection install ansible.posix

# Get installation files
git clone https://github.com/rjohnsen/threathunting-workstation.git workstation
cd workstation/
git checkout v2
git pull

# Set password for OpenSearch
read -s -p "Enter new OpenSearch Admin password: " pass
sed -i "s/REPLACEME/$pass/g" docker-compose.yml

# Run Ansible playbook
ansible-playbook -c hosts.ini opensearch.yml
