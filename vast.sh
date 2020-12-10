#!/bin/bash

git_user=$1
git_pswd=$2
git_proj=$3

wget https://raw.githubusercontent.com/vast-ai/vast-python/master/vast.py -O vast; chmod +x vast;
./vast set api-key {VAST_KEY}

apt-get update 
apt-get -y install zsh
apt-get -y install vim
apt-get -y install git
apt-get -y install gcc
apt-get -y install wget
apt-get -y install apt-transport-https ca-certificates gnupg
apt-get -y install sudo
apt-get -y install zip unzip
apt-get -y install screen
apt-get -y install curl
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
apt-get update && apt-get -y install google-cloud-sdk
gcloud auth activate-service-account --key-file {GCLOUD SERVICE KEY}

python3 -m pip install --user --upgrade pip
pip install --upgrade pip

git clone https://$git_user:$git_pswd@github.com/$git_user/$git_proj.git

