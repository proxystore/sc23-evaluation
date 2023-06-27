# SC23 ProxyStore Analysis

[![DOI](https://zenodo.org/badge/527674090.svg)](https://zenodo.org/badge/latestdoi/527674090)

Data, analysis, and figures for the SC23 ProxyStore paper titled
"Accelerating Communications in Federated Applications with Transparent
Object Proxies". Read the preprint at https://arxiv.org/abs/2305.09593.

## Get Started

```bash
$ virtualenv venv
$ . venv/bin/activate
$ pip install -r requirements.txt
$ jupyter-lab
```

## Overview

Each experiment is in its own Jupyter Notebook.
Notebooks are prefixed by a number to organize them in logical order
(i.e., the order in which they appear in the paper).

The data used by the notebooks (logs, CSVs, etc.) is placed in the `data/`
directory and figures should be output to `figures/`.

## SC23 AD/AE

Our analysis of the raw data can be found in the provided notebooks.
In addition, a Dockerfile and instructions for running
mini versions of some of the experiments are provided in `sc23-ae/`.
