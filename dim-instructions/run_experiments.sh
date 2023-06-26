#!/bin/bash

rep=5
bench=../sc23-proxystore-analysis/data/1-proxystore-with-faas-rdma/chameleon-noop.csv
globus_compute_inputs="1 10 100 1000 10000 100000"
input_sizes="1 10 100 1000 10000 100000 1000000 10000000 100000000 1000000000"
HOST=$(hostname -I | awk -F ' ' '{print $NF}')


ep=$1 # globus-compute-endpoint
exp=$2 # 0 = all, 1 = zmq, 2 = margo, 3 = redis, 4 = dspaces, 5 = globus_compute

echo $exp

if [ $exp == 1 ] || [ $exp == 0 ]
then
        python -m psbench.benchmarks.globus_compute_tasks --globus-compute-endpoint $ep --output-sizes 0 --input-sizes ${input_sizes} --ps-backend ZMQ --ps-interface eno1 --ps-port 60000 --task-repeat $rep --csv-file $bench
fi

if [ $exp == 2 ] || [ $exp == 0 ]
then
        python -m psbench.benchmarks.globus_compute_tasks --globus-compute-endpoint $ep --output-sizes 0 --input-sizes ${input_sizes} --ps-backend MARGO --ps-port 55000 --ps-margo-protocol verbs --task-repeat $rep --csv-file $bench
fi


if [ $exp == 3 ] || [ $exp == 0 ]
then
        python -m psbench.benchmarks.globus_compute_tasks --globus-compute-endpoint $ep --output-sizes 0 --input-sizes ${input_sizes} --ps-backend REDIS --ps-host ${HOST} --ps-port 6379 --task-repeat $rep --csv-file $bench
fi


if [ $exp == 4 ] || [ $exp == 0 ]
then
        pkill -f dspaces_server
        dspaces_server verbs &
        python -m psbench.benchmarks.globus_compute_tasks --globus-compute-endpoint $ep --output-sizes 0 --input-sizes ${input_sizes} --dspaces --task-repeat $rep --csv-file $bench
        pkill -f dspaces_server
fi

if [ $exp == 5 ] || [ $exp == 0 ]
then
        python -m psbench.benchmarks.globus_compute_tasks --globus-compute-endpoint $ep --output-sizes 0 --input-sizes ${globus_compute_inputs}  --task-repeat $rep --csv-file $bench
fi

if [ $exp == 6 ] || [ $exp == 0 ]
then
        python -m psbench.benchmarks.globus_compute_tasks --globus-compute-endpoint $ep --output-sizes 0 --input-sizes ${input_sizes} --ps-backend UCX --ps-port 60001 --task-repeat $rep --ps-interface eno1 --csv-file $bench
fi
