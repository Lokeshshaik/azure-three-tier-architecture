#!/bin/bash

set -e

sudo apt update
sudo apt install mysql-server -y

sudo systemctl enable mysql
sudo systemctl start mysql

echo "MySQL installation completed."