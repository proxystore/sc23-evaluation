#!/bin/bash

set -eux -o pipefail

ENDPOINT="psbench-qps-sc23-docker"

# Configure and start a ProxyStore endpoint
proxystore-endpoint configure $ENDPOINT
# Increase maximum object size of endpoint
sed -i 's/"max_object_size": 100000000,/"max_object_size": null,/' $HOME/.local/share/proxystore/$ENDPOINT/config.json
proxystore-endpoint start $ENDPOINT
PS_ENDPOINT_UUID=$(proxystore-endpoint list | grep ${ENDPOINT:0:12} | awk '{print $3}')

python -m psbench.benchmarks.endpoint_qps \
    $PS_ENDPOINT_UUID \
    --routes GET SET \
    --payload-sizes 1000 10000 100000 1000000 10000000 \
    --queries 1000 \
    --workers 1 2 3 4 \
    --csv-file /results/endpoint-qps.csv

# Stop our background processes
proxystore-endpoint stop $ENDPOINT

echo "Done!"
