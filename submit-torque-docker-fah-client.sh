#!/bin/bash
#
# Set low priority
#PBS -p -1024
#
# Array job: Run 10 WUs total, allowing 2 to run at a time.
#PBS -t 1-4%2
#
# Set a maximum wall time greater than the time per WU (or else no WUs will finish)
#PBS -l walltime=12:00:00
#
# Use the GPU queue
#PBS -q gpu
#
# Reserve one GPU
#PBS -l nodes=1:ppn=1:gpus=1:exclusive

# Set the project key here.
export PROJECT_KEY="11400"

# Change to working directory
cd "$PBS_O_WORKDIR"

# Set CUDA_VISIBLE_DEVICES
export CUDA_VISIBLE_DEVICES=`cat $PBS_GPUFILE | awk -F"-gpu" '{ printf A$2;A=","}'`

hostname
date

# Run exactly one work unit
/usr/bin/docker run --device /dev/nvidiactl:/dev/nvidiactl --device /dev/nvidia-uvm:/dev/nvidia-uvm --device /dev/nvidia${CUDA_VISIBLE_DEVICES}:/dev/nvidia0 jchodera/docker-fah-client /bin/sh -c "cd fah && ./FAHClient --client-type=INTERNAL --project-key=${PROJECT_KEY} --max-units=1"

date