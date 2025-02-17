#!/bin/bash

./configure gfortran opt --prefix="${PREFIX}" --with-pyoorb \
  --with-f2py=$(which f2py) --with-python="${PYTHON}"
make
make install
