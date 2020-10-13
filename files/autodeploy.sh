#!/bin/bash

git clone https://github.com/pvrmza/docker-observium.git 
cd docker-observium
cp env_mysql_example .env_mysql
cp env_observium_example .env_observium
docker-compose up -d


