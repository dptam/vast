#!/bin/bash

instance_id=$(./vast search offers 'verified=true, num_gpus=1, dlperf>15, dlperf<24, dlperf_usd>90, reliability > 0.98' -o 'dlperf_usd-' | head -n 2 | tail -n 1 | awk '{print $1}')
./vast create instance $instance_id --image pytorch/pytorch --disk 32
