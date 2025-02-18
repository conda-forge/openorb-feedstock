#!/bin/bash

set -ex

if [[ "${CONFIG}" == *_python3.12* ]]; then
  # export CONDA_LIBORB="pyoorb.pyf ../main/io.f90 ../python/*.f90 ../classes/*.f90 ../modules/*.f90"
  export CONDA_LIBORB="pyoorb.pyf -loorb -L../lib"
else
  export CONDA_LIBORB="-m pyoorb pyoorb.o pyoorb.pyf ../lib/liboorb.a"
fi

./configure gfortran opt --prefix="${PREFIX}" --with-pyoorb \
  --with-f2py=$(which f2py) --with-python="${PYTHON}"
make -j${CPU_COUNT}
make install
