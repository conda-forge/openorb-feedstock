#!/bin/bash

./configure gfortran opt --prefix="${PREFIX}" --with-pyoorb \
  --with-f2py=$(which f2py) --with-python="${PYTHON}"
make || {
    ls -lah $SRC_DIR/build/_pyoorb_build/bbdir/meson-private/sanitycheckf.exe
    . $SRC_DIR/build/_pyoorb_build/bbdir/meson-private/sanitycheckf.exe
    cat $SRC_DIR/build/_pyoorb_build/bbdir/meson-logs/meson-log.txt
    exit 1
}
make install
