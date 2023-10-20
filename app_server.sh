#!/bin/bash

# Update system 
apt-get update

# Install addtional packages
apt-get install default-jre -y
apt-get install software-properties-common -y
add-apt-repository -y ppa:deadsnakes/ppa 
apt-get install python3.7 -y
apt-get install python3.7-venv -y
