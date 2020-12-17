#!/bin/bash

git_user=$1
git_pswd=$2
git_proj=$3
config_file=$4

instance_id=$(./vast search offers 'verified=true, num_gpus=1, dlperf>15, dlperf<24, dlperf_usd>90, reliability > 0.98' -o 'dlperf_usd-' | head -n 2 | tail -n 1 | awk '{print $1}')
output=$(./vast create instance $instance_id --image pytorch/pytorch --disk 32)
instance_id=$(echo $output | awk -F"[{}]" '{print $2}' | awk -F"[:]" '{print $3}' | xargs)

until [ "$(./vast show instances | awk -v instance_id="$instance_id"  '$1 ~ instance_id' | awk '{print $3}')" == "running" ];
do
    echo "Waiting 10 second ..."
    sleep 10
done
sleep 25
echo "Setup instance..."

ssh_addr=$(./vast show instances | awk -v instance_id="$instance_id"  '$1 ~ instance_id' | awk '{print $10}')
ssh_port=$(./vast show instances | awk -v instance_id="$instance_id"  '$1 ~ instance_id' | awk '{print $11}')
scp -o StrictHostKeyChecking=no -v -P  $ssh_port vast.sh root@$ssh_addr:/root/
scp -o StrictHostKeyChecking=no -v -P $ssh_port {GCLOUD CONFIG KEY} root@$ssh_addr:/root/
ssh -o StrictHostKeyChecking=no -p $ssh_port root@$ssh_addr -L 8080:localhost:8080 "tmux new -d 'export PATH=/opt/conda/bin:$PATH; source vast.sh $git_user $git_pswd $git_proj; cd $git_proj; source bin/init.sh; source bin/setup.sh; bash bin/train.sh $config_file &> output'; bash bin/write_output.sh; cd ..; ./vast destroy instance $instance_id"

