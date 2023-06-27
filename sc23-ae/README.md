# SC23 AD/AE Scripts

This directory contains a Docker image for running `psbench`, the suite
of ProxyStore microbenchmarks found at
[proxystore/benchmarks](https://github.com/proxystore/benchmarks).
Scripts are only provided for the benchmarks which can be run on
a single machine, and the scopes of some benchmarks have been reduced to ensure
these examples can run on most hardware (e.g., a laptop). A full list of the
microbenchmarks and the documentation to run them can be found
[here](https://github.com/proxystore/benchmarks/tree/main/docs).

The provided Dockerfile will install the `psbench` package, any dependencies,
and copy the bash scripts for executing each experiment.
Each experiment is designed to take at most around five minutes depending
on hardware.

The `chameleon-cloud/` directory contains scripts for running
another experiment on specific Chameleon Cloud node types. We suggest starting
with the scripts in this README before trying the Chameleon Cloud experiment.
Instructions for the Chameleon Cloud experiment are found in
[chameleon-cloud/README.md](chameleon-cloud/README.md).

## Setup

**Clone the repository.**
```bash
$ git clone https://github.com/proxystore/sc23-proxystore-analysis.git
```

**Build the Docker image.**
```bash
$ cd sc23-proxystore-analysis/sc23-ae
$ docker build -t psbench-sc23 .
```

All of the following commands assume you are working in this directory.

## Experiment 1: Globus Compute Tasks

> The documentation for this experiment can be found
> [here](https://github.com/proxystore/benchmarks/blob/main/docs/globus-compute-tasks.md).

*Note: Globus Compute was formerly called FuncX.*

This experiment starts a Globus Compute endpoint in the container and then
invokes tasks on the endpoint. The tasks are no-ops and the round-trip task
time is recorded to measure data transfer overheads.
Tasks are repeated over a range of input data sizes and ProxyStore connectors.
This experiment is a small version of that presented in Section 5.1 of the
paper.

The script will create a Globus Compute Endpoint which requires authorization
with Globus. You will be prompted to open a Globus link to complete the
authorization process (requires logging in with your institution credentials)
after which you will be provided a token to copy and
paste back to the application. This authentication will need to be performed
each time the Docker container is restarted because the tokens will be lost.

Use the following command to run the experiment. A CSV logging the timing
information of each task will be written to
`./results/globus-compute-tasks.csv`.

```
docker run -it --rm --network host -v $(pwd)/results:/results psbench-sc23 /bin/bash -c '/workspace/globus-compute-tasks.sh'
```

## Experiment 2: Colmena Tasks

> The documentation for this experiment can be found
> [here](https://github.com/proxystore/benchmarks/blob/main/docs/colmena-rtt.md).

This experiment measures round-trip task time for Colmena, a workflow system
for ensembles of simulations powered by Parsl.
Tasks are repeated over a range of input/output data sizes and ProxyStore
connectors. This experiment corresponds to Section 5.2 of the paper.

Use the following command to run the experiment. A CSV logging the timing
information of each task will be written to `./results/colmena-tasks.csv`.

```
docker run -it --rm --network host -v $(pwd)/results:/results psbench-sc23 /bin/bash -c '/workspace/colmena-tasks.sh'
```

## Experiment 3: Endpoint Client Performance

> The documentation for this experiment can be found
> [here](https://github.com/proxystore/benchmarks/blob/main/docs/endpoint-qps.md).

This experiment measures the queries per second a ProxyStore Endpoint can
achieve across a variety of concurrent clients and payload sizes.
This experiment corresponds to Section 5.3.1 of the paper.

Use the following command to run the experiment. A CSV logging the timing
information will be written to `./results/endpoint-qps.csv`.

```
docker run -it --rm -v $(pwd)/results:/results psbench-sc23 /bin/bash -c '/workspace/endpoint-qps.sh'
```

## Visualization

The results of these experiments can be visualized in the `visualize.ipynb`
Jupyter Notebook. The notebook will produce a graph for each experiment that
is similar to the corresponding graph from the paper.

To run the notebook, follow the "Get Started" instructions in
[`../README.md`](../README.md).
