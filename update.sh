#!/usr/bin/env bash

sudo docker compose down
sudo docker compose pull
sudo docker compose up -d --remove-orphans
sudo docker image prune
