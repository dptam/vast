#!/bin/bash

instance_id=$1
git_user=$2
git_pswd=$3
git_proj=$4

until [ "$(./vast show instances | awk -v instance_id="$instance_id"  '$1 ~ instance_id' | awk '{print $3}')" == "running" ];
do
    echo "Waiting 5 second ..."
    sleep 5
done
echo "Setup instance..."

ssh_addr=$(./vast show instances | awk -v instance_id="$instance_id"  '$1 ~ instance_id' | awk '{print $10}')
ssh_port=$(./vast show instances | awk -v instance_id="$instance_id"  '$1 ~ instance_id' | awk '{print $11}')
scp -o StrictHostKeyChecking=no -v -P  $ssh_port vast.sh root@$ssh_addr:/root/
scp -o StrictHostKeyChecking=no -v -P $ssh_port {GCLOUD CONFIG KEY} root@$ssh_addr:/root/
ssh -o StrictHostKeyChecking=no -p $ssh_port root@$ssh_addr -L 8080:localhost:8080 "export PATH=/opt/conda/bin:$PATH; source vast.sh $git_user $git_pswd $git_proj"
ssh -o StrictHostKeyChecking=no -p $ssh_port root@$ssh_addr -L 8080:localhost:8080 "export PATH=/opt/conda/bin:$PATH; cd $git_proj; source bin/init.sh"
