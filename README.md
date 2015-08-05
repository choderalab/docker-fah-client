# docker-fah-client
Information on running the Folding@Home client inside a docker image on hal.cbio.mskcc.org

Note that you must first request to be added to the `docker` access group by [posting to the hal GitHub issue tracker](https://github.com/cbio/cbio-cluster/issues).

We use the [`kaixhin/cuda-torch`](https://registry.hub.docker.com/u/kaixhin/cuda-torch/) docker instance.

```
# Interactive shell
qsub -I -l walltime=04:00:00,nodes=1:ppn=1:gpus=1:shared -l mem=4G -q active


# Create a docker instance and drop into a bash shell
docker run -it --device /dev/nvidiactl:/dev/nvidiactl --device /dev/nvidia-uvm:/dev/nvidia-uvm --device /dev/nvidia${CUDA_VISIBLE_DEVICES}:/dev/nvidia0 kaixhin/cuda-torch bash

# Install the FAHClient
wget https://fah.stanford.edu/file-releases/public/release/fahclient/centos-5.3-64bit/v7.4/fahclient-7.4.4-1.x86_64.rpm
mkdir fahclient
cd fahclient
rpm2cpio ../fahclient-7.4.4-1.x86_64.rpm | cpio -idmv
```

Creating our own docker instance?

```
# Start with CUDA base image
FROM kaixhin/cuda
MAINTAINER Kai Arulkumaran <design@kaixhin.com>

# Install curl and dependencies for iTorch
RUN apt-get update && apt-get install -y \
  curl \
  wget \
  ipython3 \
  python-zmq

# Run FAH installation scripts
RUN wget https://fah.stanford.edu/file-releases/public/release/fahclient/centos-5.3-64bit/v7.4/fahclient-7.4.4-1.x86_64.rpm
RUN rpm -i fahclient-7.4.4-1.x86_64.rpm
```

# Building the docker image
```
docker build .
```

Complete just one work unit!
```
docker run -it --device /dev/nvidiactl:/dev/nvidiactl --device /dev/nvidia-uvm:/dev/nvidia-uvm --device /dev/nvidia${CUDA_VISIBLE_DEVICES}:/dev/nvidia0 kaixhin/cuda-torch cd fah && ./FAHClient client-type=INTERNAL project-key=10495 max-units=1 
```