#!/bin/bash
sudo apt-get update && sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu
docker run -d -p 8080:80 --name mynginx nginx