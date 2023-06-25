FROM python:3.10.12-bullseye

WORKDIR /workspace

RUN git clone https://github.com/proxystore/benchmarks \
    && cd benchmarks \
    && pip install -e .

RUN apt -y update && apt install -y redis-server

COPY scripts/ /workspace
