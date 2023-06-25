#!/bin/bash

set -eux -o pipefail

ENDPOINT="psbench-gc-sc23-docker"
BASELINE_INPUT_SIZES="100 1000 10000 100000 1000000"
PROXYSTORE_INPUT_SIZES="${BASELINE_INPUT_SIZES} 10000000 100000000"

# Configure endpoint, record UUID, and start it. Configuration will require
# the user to authenticate with Globus using a provided link.
globus-compute-endpoint configure $ENDPOINT
globus-compute-endpoint start $ENDPOINT
GC_ENDPOINT_UUID=$(globus-compute-endpoint list | grep $ENDPOINT | awk '{print $2}')

# Configure and start a ProxyStore endpoint
proxystore-endpoint configure $ENDPOINT
# Increase maximum object size of endpoint
sed -i 's/"max_object_size": 100000000,/"max_object_size": null,/' $HOME/.local/share/proxystore/$ENDPOINT/config.json
proxystore-endpoint start $ENDPOINT
PS_ENDPOINT_UUID=$(proxystore-endpoint list | grep ${ENDPOINT:0:12} | awk '{print $3}')

# Start the redis server
REDIS_PORT=59465
redis-server --port $REDIS_PORT --protected-mode no &> redis.out &
REDIS_SERVER_PID=$!

ARGS="--globus-compute-endpoint ${GC_ENDPOINT_UUID} "
ARGS+="--output-sizes 0 "
ARGS+="--csv-file /results/globus-compute-tasks.csv "
ARGS+="--task-repeat 5 "

echo "Running with Globus Compute Endpoint ${GC_ENDPOINT_UUID}"
echo "Running with ProxyStore Endpoint ${PS_ENDPOINT_UUID}"

# Baseline (without ProxyStore)
python -m psbench.benchmarks.globus_compute_tasks $ARGS \
    --input-sizes $BASELINE_INPUT_SIZES

# ProxyStore FileConnector
python -m psbench.benchmarks.globus_compute_tasks $ARGS \
    --input-sizes $PROXYSTORE_INPUT_SIZES \
    --ps-backend FILE --ps-file-dir /tmp/proxystore-dump

# ProxyStore RedisConnector
python -m psbench.benchmarks.globus_compute_tasks $ARGS \
    --input-sizes $PROXYSTORE_INPUT_SIZES  \
    --ps-backend REDIS --ps-host localhost --ps-port $REDIS_PORT

# ProxyStore EndpointConnector
python -m psbench.benchmarks.globus_compute_tasks $ARGS \
    --input-sizes $PROXYSTORE_INPUT_SIZES  \
    --ps-backend ENDPOINT --ps-endpoints $PS_ENDPOINT_UUID

# ProxyStore ZeroMQConnector
python -m psbench.benchmarks.globus_compute_tasks $ARGS \
    --input-sizes $PROXYSTORE_INPUT_SIZES  \
    --ps-backend ZMQ --ps-port 15920

# Stop our background processes
proxystore-endpoint stop $ENDPOINT
kill $REDIS_SERVER_PID
globus-compute-endpoint stop $ENDPOINT
globus-compute-endpoint delete --force --yes $ENDPOINT

echo "Done!"
