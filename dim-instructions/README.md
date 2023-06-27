## Reproducing the Distributed In-memory store experiments

The following scripts can be used to reproduce the results obtained and presented in Figure 5 of the paper
(specifically, the Chameleon results within Figure 5).

To run these experiments, two compute-haswell-ib VMs from CHI@TACC with CC-Ubuntu20.04
(hash: ecb2ffc4-90a8-4c8b-b9ed-a141392d8359) installed, are required.

Steps:
1. Clone this repository onto both VMs \
`git clone -b dim-instructions https://github.com/proxystore/sc23-proxystore-analysis.git`
2. Execute the `setup-chameleon.sh` binary provided to configure the environment on both VMs \
**Note**: This script may fail at times, particularly during the Spack installation due to timeouts \
it is recommended to run Spack install, until all packages are successfully installed, outside of the script \
before proceeding with the remaining commands \
`bash sc23-proxystore-analysis/dim-instructions/setup-chameleon.sh`
4. Configure a Globus-Compute endpoint on one of the VMs \
   **Note**: you will be required to authenticate via Globus
   ```
    globus-compute-endpoint configure ps-sc23
    globus-compute-endpoint start ps-sc23
   ```
5.  Copy the endpoint id generated and use it to run the benchmarks in the other VM \
    **Note**: you will be required to authenticate via Globus \
    ```
    bash run_experiments.sh <endpoint_id> 0
    ```
7. The results will be saved to the `sc23-proxystore-analysis/data/repro-chameleon-noop.csv` and can be
   visualized with the help of `1-proxystore-with-faas-rdma.ipynb`

 ### Files in current directory
 - `redis.conf` contains the Redis configuration used for running the experiments on both Polaris and Chameleon
 - `run_experiments.sh` is the script used to execute the experiments. It takes and Globus Compute Endpoint ID and \
 an integer represention which benchmarks to run (i.e., 0 = all, 1 = zmq, 2 = margo, 3 = redis, 4 = dspaces, 5 = globus_compute)
 - `setup-chameleon.sh` is the Chameleon setup script. It configures the VM for Infiniband and sets a static IP for the network, installs Spack and uses the `spack-chameleon.yml` to configure the environment, and installs other dependencies for running the benchmarks
 - `spack-chameleon.yml` is the Spack environment configuration file for the Chameleon microbenchmarks.
 - `spack-polaris.yml` is the Spack environment configuration file for the Polaris microbenchmarks.


