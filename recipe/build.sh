#!/bin/bash

set -ex

if [[ "${CONFIG}" == *_python3.12* ]]; then
  export MESON_ARGS=${MESON_ARGS//--prefix=${PREFIX}/""}
  export CONDA_LIBORB="pyoorb.pyf ../main/io.f90 ../python/*.f90 ../classes/*.f90 ../modules/*.f90 ${MESON_ARGS}"
  export FFLAGS="${FFLAGS} -I${SRC_DIR}/build"
  export CFLAGS="${CFLAGS} -I${SRC_DIR}/build"
else
  export CONDA_LIBORB="-m pyoorb pyoorb.o pyoorb.pyf ../lib/liboorb.a"
fi

./configure gfortran opt --prefix="${PREFIX}" --with-pyoorb \
  --with-f2py=$(which f2py) --with-python="${PYTHON}"
make -j${CPU_COUNT}
make install
