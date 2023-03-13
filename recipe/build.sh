#!/bin/bash

./configure gfortran opt --prefix="$PREFIX" --with-pyoorb
make
make install
