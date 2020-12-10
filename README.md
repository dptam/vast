# Vast

This repo contains scripts to run experiments on vast.ai. Experiments are stored on Google Cloud Storage and tracked on Weights and Bias. This allows for everything to run locally, since progress can be tracked onto W&B rather than logging onto the instance


## Before running

This assumes a vast key and google cloud key have been generated. Replace `{vast key}` in `vast.sh` with your vast key and `{GCLOUD CONFIG KEY}` in `setup_instance.sh` and `run_job.sh` with the google cloud json key. Also, this assumes the github project has a bin folder which contains 
  * `init.sh` script that installs datasets and setups the environment
  * `train.sh`script that runs the experiments and takes a `{config_file}` as an argument


## Workflow (Option 1)

1. Start cloud instance using `start_instance.sh`. 
    * Currently, the script is configured to start a 2080ti instance 
2. Setup cloud instance with `setup_instance.sh` passing in the `{instance_id}`, `{github_username}`, `{github_password}`, `{github_project}`. This will 
    * Copy `vast.sh` script to cloud instance. 
    * Copy Google Cloud json key to the cloud instance 
    * Run `vast.sh` on the cloud instance to install general packages and the github project. 
    * Run `bin/init.sh` in the github project on the cloud instance to install project datasets and setup python environment 
3. Run job with `start_job.sh` passing in the `{instance_id}`, `{github_username}`, `{github_password}`, `{github_project}`, and `{config_file}`. 
    * Start the job running on the cloud instance. This script assumes that `bin/train.sh` in the github project takes in a config file to start a job. 

* Note that all commands on the cloud instance are run through ssh tunneling, and so the output will still be local. 

## Workflow (Option 2)
1. Run `run_job.sh` that combines all the steps above, taking in the arguments `{github_username}`, `{github_password}`, `{github_project}`, and `{config_file}`. 
    * One difference is that this will run all commands on the cloud instance as a background process. 


## Commands Explained 
1. `./vast search offers 'verified=true, num_gpus=1, dlperf>15, dlperf<24, dlperf_usd>90, reliability > 0.98' -o 'dlperf_usd-'` 
      * Filters for verfied 2080ti (from dlperf) that are reliable 
      * Orders by highest dlperf_usd (deep learning performance per US dollar)
2. `instance_id=$(./vast search offers 'verified=true, num_gpus=1, dlperf>15, dlperf<24, dlperf_usd>90, reliability > 0.98' -o 'dlperf_usd-' | head -n 2 | tail -n 1 | awk '{print $1}')`
    * Get instance_id of instance to start 
3. `./vast create instance $instance_id --image pytorch/pytorch --disk 32` 
    * Sart instance 
4. `ssh_addr=$(./vast show instances | awk -v instance_id="$instance_id"  '$1 ~ instance_id' | awk '{print $10}')` and `ssh_port=$(./vast show instances | awk -v instance_id="$instance_id"  '$1 ~ instance_id' | awk '{print $11}')
` 
    * Get the address and port of cloud instance 
5. `scp -v -P $ssh_port vast.sh root@$ssh_addr:/root/` and `ssh -p $ssh_port root@$ssh_addr -L 8080:localhost:8080 "export PATH=/opt/conda/bin:$PATH; source vast.sh $github_username $github_password $github_repo"`
    * Copy `vast.sh` to server and run it to install general packages and github repo 
6. `ssh -p $ssh_port root@$ssh_addr -L 8080:localhost:8080 "export PATH=/opt/conda/bin:$PATH; cd $git_proj; bash bin/init.sh"` 
    * Install datasets and setup enviroment for project 
7. `ssh -p $ssh_port root@$ssh_addr -L 8080:localhost:8080 "export PATH=/opt/conda/bin:$PATH; cd $git_proj; bash bin/setup.sh;  bash bin/train.sh $config_file"` 
    * Start training 
8. `./vast destroy instance $instance_id` 
    * Destroy remote instance 
