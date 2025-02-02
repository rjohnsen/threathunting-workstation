#!/bin/env bash

echo "Threathunting Workstation - Installer"
echo "By Roger C.B. Johnsen - www.predefender.com"
echo ""

# Install Ansible and Git
sudo apt install git ansible -y

# Install requirements for Ansible installation script
sudo ansible-galaxy collection install ansible.posix

# Make room for predefender tools
mkdir /opt/predefender
cd /opt/predefender

# Get installation files
git clone https://github.com/rjohnsen/threathunting-workstation.git threathunting-workstation
cd threathunting-workstation/
git checkout v2
git pull

# Set password for OpenSearch
read -s -p "Enter new OpenSearch Admin password: " pass
touch .env
echo "OPENSEARCH_INITIAL_ADMIN_PASSWORD=$pass" | tee -a .env

# Run Ansible playbook
ansible-playbook -c hosts.ini ubuntu.yml
