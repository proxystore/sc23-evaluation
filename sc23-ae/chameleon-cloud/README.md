# Chameleon Cloud Experiment

This directory contains instructions and scripts for reproducing
the experiment in the paper which used Chameleon Cloud to evaluate the
distributed in-memory Connectors provided by ProxyStore (Figure 5).

The experiment requires two compute-haswell-ib VMs from CHI@TACC with
CC-Ubuntu20.04 (hash: ecb2ffc4-90a8-4c8b-b9ed-a141392d8359) installed.

## Instructions

1. Clone this repository onto both VMs.
   ```bash
   $ git clone https://github.com/proxystore/sc23-proxystore-analysis
   $ cd sc23-proxystore-analysis/sc23-ae/chameleon-cloud
   ```
2. Execute the `setup-chameleon.sh` script on both VMs to configure the
   environment.

   **Note**: This script may fail at times, particularly during the Spack
   installation due to timeouts. We recommend running Spack install, until all
   packages are successfully installed, outside of the script before proceeding
   with the remaining commands.
4. Configure a Globus-Compute endpoint on one of the VMs.
   **Note**: you will be required to authenticate via Globus.
   ```bash
   $ globus-compute-endpoint configure ps-sc23
   $ globus-compute-endpoint start ps-sc23
   ```
5. Copy the endpoint ID generated and use it to run the benchmarks in the
   other VM. **Note**: you will be required to authenticate via Globus.
   ```bash
   $ bash run-experiments.sh <endpoint_id> 0
   ```
7. The results will be saved to
   `sc23-proxystore-analysis/data/repro-chameleon-noop.csv` and can be
   visualized with the help of `1-proxystore-with-faas-rdma.ipynb` in the
   root directory of the repository. Note that the original data referred to
   each ProxyStore configuration as "XStore" but these scripts will refer to
   "XConnector" in the output files.

## Provided Files

* `redis.conf` contains the Redis configuration used for running the experiments
  on both Polaris and Chameleon.
* `run-experiments.sh` is the script used to execute the experiments.
  It takes the Globus Compute Endpoint ID and an integer representation of which
  benchmark configurations to run (i.e., 0 = all, 1 = zmq, 2 = margo,
  3 = redis, 4 = dspaces, 5 = globus_compute).
* `setup-chameleon.sh` is the Chameleon setup script. It configures the VM for
  Infiniband and sets a static IP for the network, installs Spack and uses
  the `spack-chameleon.yml` to configure the environment, and installs other
  dependencies for running the benchmarks.
* `spack-chameleon.yml` is the Spack environment configuration file for the Chameleon.
* `spack-polaris.yml` is the Spack environment configuration file for the Polaris.
