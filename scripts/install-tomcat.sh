#!/bin/bash

set -e

sudo apt update

sudo apt install openjdk-17-jdk -y

sudo apt install tomcat10 -y

sudo systemctl enable tomcat10
sudo systemctl start tomcat10

echo "Tomcat installation completed."