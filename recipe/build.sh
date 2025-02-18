#!/bin/bash

set -ex

export FFLAGS="${FFLAGS} -I../../../build -L../../../lib"

./configure gfortran opt --prefix="${PREFIX}" --with-pyoorb \
  --with-f2py=$(which f2py) --with-python="${PYTHON}"
make -j${CPU_COUNT} || {
    cat $SRC_DIR/build/_pyoorb_build/bbdir/meson-logs/meson-log.txt
    exit 1
}
make install
