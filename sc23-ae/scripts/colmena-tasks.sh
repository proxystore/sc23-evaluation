#!/bin/bash

set -eux -o pipefail

# Start the redis server
REDIS_PORT=59465
redis-server --port $REDIS_PORT --protected-mode no &> redis.out &
REDIS_SERVER_PID=$!

ARGS="--parsl "
ARGS+="--input-sizes 1 100 10000 1000000 10000000 "
ARGS+="--output-sizes 1 100 10000 1000000 10000000 "
ARGS+="--csv-file /results/colmena-tasks.csv "
ARGS+="--task-repeat 5 "
ARGS+="--redis-host localhost "
ARGS+="--redis-port ${REDIS_PORT} "

# Baseline (without ProxyStore)
python -m psbench.benchmarks.colmena_rtt $ARGS

# ProxyStore FileConnector
python -m psbench.benchmarks.colmena_rtt $ARGS \
    --ps-backend FILE --ps-file-dir /tmp/proxystore-dump

# ProxyStore RedisConnector
python -m psbench.benchmarks.colmena_rtt $ARGS \
    --ps-backend REDIS --ps-host localhost --ps-port $REDIS_PORT

# Stop our background processes
kill $REDIS_SERVER_PID

echo "Done!"
