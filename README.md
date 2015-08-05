# docker-fah-client

Running the Folding@home client inside a docker image.

## Running on the `hal.cbio.mskcc.org` cluster at MSKCC

Note that you must first request to be added to the `docker` access group by [posting to the hal GitHub issue tracker](https://github.com/cbio/cbio-cluster/issues).

Sample `submit-torque-docker-fah-client.sh` Torque/Moab script:
```
#!/bin/bash
#
# Set low priority
#PBS -p -1024
#
# Array job: Run 10 WUs total, allowing 2 to run at a time.
#PBS -t 1-10%2
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
export PROJECT_KEY=10495

# Change to working directory
cd "$PBS_O_WORKDIR"

# Set CUDA_VISIBLE_DEVICES
export CUDA_VISIBLE_DEVICES=`cat $PBS_GPUFILE | awk -F"-gpu" '{ printf A$2;A=","}'`

# Run exactly one work unit
docker run --device /dev/nvidiactl:/dev/nvidiactl --device /dev/nvidia-uvm:/dev/nvidia-uvm --device /dev/nvidia${CUDA_VISIBLE_DEVICES}:/dev/nvidia0 jchodera/docker-fah-client /bin/sh -c 'cd fah && ./FAHClient --client-type=INTERNAL --project-key=$PROJECT_KEY --max-units=1'
```


## Testing in an interactive shell

You can drop into an interactive shell using
```
qsub -I -l walltime=04:00:00 -l nodes=1:ppn=1:gpus=1:exclusive -l mem=4G -q active
```

Assuming `CUDA_VISIBLE_DEVICES` is set correctly by Torque/Moab, you can run docker using
```
docker run -it --device /dev/nvidiactl:/dev/nvidiactl --device /dev/nvidia-uvm:/dev/nvidia-uvm --device /dev/nvidia${CUDA_VISIBLE_DEVICES}:/dev/nvidia0 jchodera/docker-fah-client /bin/sh -c 'cd fah && ./FAHClient --client-type=INTERNAL --project-key=$PROJECT_KEY --max-units=1'
```

## Acknowledgments

The `jchodera/docker-fah-client` image is based on the excellent `kaixhin/cuda` CUDA-enabled docker instance.

Thanks to Patrick Grinaway for discovering it was possible to run a Folding@home client inside a docker instance.

