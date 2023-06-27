## Reproducing the Distributed In-memory store experiments

The following scripts can be used to reproduce the results obtained and presented in Figure 5 of the paper
(specifically, the Chameleon results within Figure 5).

To run these experiments, two compute-haswell-ib VMs from CHI@TACC with the CC-Ubuntu20.04
(hash: ecb2ffc4-90a8-4c8b-b9ed-a141392d8359) installed are required.

Steps:
1. Clone this repository onto both VMs \
`git clone -b dim-instructions https://github.com/proxystore/sc23-proxystore-analysis.git`
3. Execute the `setup-chameleon.sh` binary provided to configure the environment on both VMs \
`bash sc23-proxystore-analysis/dim-instructions/setup-chameleon.sh`
4. Configure a Globus-Compute endpoint on one of the VMs \
   Note: you will be required to authenticate via Globus
   ```
    globus-compute-endpoint configure ps-sc23
    globus-compute-endpoint start ps-sc23
   ```
5.  Copy the endpoint id generated and use it to run the benchmarks in the other VM \
   ```
   bash run_experiments.sh <endpoint_id> 0
   ```
6. The results will be saved to the `sc23-proxystore-analysis/data/repro-chameleon-noop.csv` and can be
   visualized with the help of `1-proxystore-with-faas-rdma.ipynb`
 


