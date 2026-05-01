#!/bin/bash

set -e

sudo DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y build-essential flex bison zlib1g-dev libmpc-dev libmpfr-dev libgmp-dev g++
