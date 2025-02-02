#!/bin/env bash

echo "Threathunting Workstation - Installer"
echo "By Roger C.B. Johnsen - www.predefender.com"
echo ""

# Get password for OpenSearch
read -p "Enter new OpenSearch Admin password: " pass

# Install Ansible and Git
sudo apt install git ansible -y

# Install requirements for Ansible installation script
sudo ansible-galaxy collection install ansible.posix

# Make room for predefender tools
mkdir /opt/predefender
mkdir /opt/predefender/logs
cd /opt/predefender


# Get installation files
git clone https://github.com/rjohnsen/threathunting-workstation.git threathunting-workstation
cd threathunting-workstation/
git checkout v2
git pull

# Set password for OpenSearch
sed -i "s/REPLACEME/$pass/g" docker-compose.yml

# Run Ansible playbook
ansible-playbook -c hosts.ini ubuntu.yml

echo "Please login to https://localhost:9443 (Portainer) and set admin password to finish the installation"