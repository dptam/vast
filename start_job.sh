#!/bin/bash

instance_id=$1
git_user=$2
git_pswd=$3
git_proj=$4
config_file=$5

until [ "$(./vast show instances | awk -v instance_id="$instance_id"  '$1 ~ instance_id' | awk '{print $3}')" == "running" ];
do
    echo "Waiting 10 second ..."
    sleep 10
done
sleep 25
echo "Starting job..."

ssh_addr=$(./vast show instances | awk -v instance_id="$instance_id"  '$1 ~ instance_id' | awk '{print $10}')
ssh_port=$(./vast show instances | awk -v instance_id="$instance_id"  '$1 ~ instance_id' | awk '{print $11}')
ssh -o StrictHostKeyChecking=no -p $ssh_port root@$ssh_addr -L 8080:localhost:8080 "tmux new -d 'export PATH=/opt/conda/bin:$PATH; cd $git_proj; source bin/setup.sh; bash bin/train.sh $config_file &> output; bash bin/write_output.sh'"
