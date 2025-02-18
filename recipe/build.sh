#!/bin/bash

set -ex

# meson is used on 3.12 and is one more directory down than where
# distutils was
if [[ "$(python -V)" == "*3.12.*" ]]; then
  # CONDA_LIBORB is hacked in via a patch
  export CONDA_LIBORB="../../lib/liboorb.a"
  export FFLAGS="${FFLAGS} -I../../../build -L../../../lib"
else
  export CONDA_LIBORB="../lib/liboorb.a"
fi

./configure gfortran opt --prefix="${PREFIX}" --with-pyoorb \
  --with-f2py=$(which f2py) --with-python="${PYTHON}"
make -j${CPU_COUNT} || {
  cat $SRC_DIR/build/_pyoorb_build/bbdir/meson-logs/meson-log.txt
  exit 1
}
make install
