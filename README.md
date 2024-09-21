# Threathunting Workstation

## About

The Threat Hunting Workstation is a complete toolkit designed to help teams establish a dedicated environment for efficient threat hunting. It features a SIEM tool for log importing and analysis, a wiki for documentation, and essential utilities for hunting and incident management. Delivered as an installation script for a virtualized instance of Alma Linux, this workstation offers a centralized, powerful solution to enhance team collaboration and streamline security operations.

## Installation

In general, the installation consists of two steps:

1. Install Alma Linux in Virtualbox. Not covered in this installation instruction. 
2. Install the Threathunting Workstation tools using the script covered in this installation instruction.


Obtain the installation script:

```bash
curl https://raw.githubusercontent.com/rjohnsen/threathunting-workstation/main/install-workstation.sh -o install-workstation.sh
```

Run setup script:

```bash
chmod +x install-workstation.sh
./install-workstation.sh
```

Then follow directions. Note: The installation will take some time.

### Service Ports

The following table displays the communication ports for each intalled service. This table also serves as a reference for setting up port forwarding for NAT Networks in Virtualbox:

| Service | Protocol | Port |
| ------- | -------- | ---- |
| OpenSearch Dashboards (main SIEM interface) |  TCP | 5601 |
| OpenSearch Logstasth | TCP | 5044 |
| OpenSearch Node Communication and Transport | TCP | 9300 |
| OpenSearch Perfomance Analyzer | TCP | 9600 |
| OpenSearch REST API | TCP | 9200 |
| Portainer | TCP | 9443 |
| SSH | TCP | TCP | 22 |
| XWiki | TCP | 8080 |
| Cyberchef | TCP | 8000 |  

### XWiki initial setup

First time reaching XWiki over the web it will kickstart its installer. The installer will guide you through four steps:

1. Admin user - make sure to create a user with administrative right
2. Flavor - install or update the flavor of this wiki. Make sure to install and use "XWiki Standard Flavor" as presented in the GUI.
3. Orphaned dependencies - make sure orphaned extension dependencies are either removed or made top level.
4. Extensions - update the installed extensions

## Architecture

### System Setup

```mermaid
flowchart LR
 B[Virtualbox]
 C[Alma Linux]
 D[Docker]
 E[OpenSearch]
 F[XWiki]
 G[Portainer]
 H[CyberChef]
 I[DFIR-IRIS]

 subgraph A[Threathunter Workstation]
    subgraph B[Virtualbox]
        C-->D
        D-->E
        D-->F
        D-->G
        D-->H
        D-. Future .->I
    end
 end
 ```

## Upgrading

These are the instructions to update the Docker container installed by the installer script. Run the following steps as _ROOT_ or via ```sudo```.

 ### Updating Alma Linux

```bash
dnf upgrade
```

### Updating Docker containers

#### Update all containers

```bash
docker compose pull
docker-compose up -d
```

After commands completes, give it some minutes before trying to reach the hosts in a browser. 

#### Verifying versions after update

##### OpenSearch

In a suitable browser, visit https://localhost:9200, log in and you'll be presented with a JSON object stating the version. Example:

```json
{
  "name" : "opensearch-node1",
  "cluster_name" : "opensearch-cluster",
  "cluster_uuid" : "N7IOLSfnSFWasG-EoI7IUg",
  "version" : {
    "distribution" : "opensearch",
    "number" : "2.17.0",
    "build_type" : "tar",
    "build_hash" : "8586481dc99b1740ca3c7c966aee15ad0fc7b412",
    "build_date" : "2024-09-13T01:04:14.707418737Z",
    "build_snapshot" : false,
    "lucene_version" : "9.11.1",
    "minimum_wire_compatibility_version" : "7.10.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "The OpenSearch Project: https://opensearch.org/"
}
```