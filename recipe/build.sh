#!/bin/bash

set -ex

export FFLAGS="${FFLAGS} -I../../../build -L../../../lib"

./configure gfortran opt --prefix="${PREFIX}" --with-pyoorb \
  --with-f2py=$(which f2py) --with-python="${PYTHON}"
make -j${CPU_COUNT}
make install
