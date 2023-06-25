FROM python:3.10.12-bullseye

WORKDIR /workspace

RUN git clone https://github.com/proxystore/benchmarks \
    && cd benchmarks \
    && pip install --no-cache-dir -e .

RUN apt-get -y update \
    && apt-get install --no-install-recommends -y redis-server \
    && apt-get clean autoclean \
    && rm -rf /var/lib/apt/lists/*

COPY scripts/ /workspace
