# docker-fah-client

Running the Folding@home client inside a docker image.

The [`jchodera/docker-fah-client`](https://registry.hub.docker.com/u/jchodera/docker-fah-client/) docker image has a copy of the Folding@home linux client inside the `/fah` directory.

## Running on `hal.cbio.mskcc.org`

Note that you must first request to be added to the `docker` access group by [posting to the hal GitHub issue tracker](https://github.com/cbio/cbio-cluster/issues).

Install the `docker-fah-client` conda package:

```
conda install -c choderalab docker-fah-client
```

Then, you can run the `fah-client` command-line helper:

```
[chodera@mskcc-ln1 ~/docker-fah-client]$ scripts/fah-client --help
usage: fah-client [-h] [--project PROJECT] [--number NUMBER]
                  [--maxworkers MAXWORKERS] [--walltime WALLTIME]
                  [--jobname JOBNAME] [--verbose]

Spin up a specified number of FAHClient instances pointed out designated
INTERNAL project inside of docker containers. 

optional arguments:
  -h, --help            show this help message and exit
  --project PROJECT     the internal project number (required)
  --number NUMBER       number of work units to process (default: 1)
  --maxworkers MAXWORKERS
                        maximum number of simultaneous wokers (default: 1)
  --walltime WALLTIME   walltime limit (default: 12:00:00)
  --jobname JOBNAME     job name (default: docker-fah-client)
  --verbose             print debug output (default: False)

```

## Running via Torque/Moab scripts

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

## Manifest

* `Dockerfile` - dockerfile for jchodera/docker-fah-client
* `scripts/` - useful scripts

## Acknowledgments

The `jchodera/docker-fah-client` image is based on the excellent [`kaixhin/cuda`](https://registry.hub.docker.com/u/kaixhin/cuda/) CUDA-enabled docker instance.

Thanks to Patrick Grinaway for discovering it was possible to run a Folding@home client inside a docker instance.

