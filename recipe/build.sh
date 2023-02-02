#!/bin/bash

# conda's gfortran on Linux does not install a binary named 'gfortran'
echo "gfortran = $(which gfortran)"
[[ ! -f "$BUILD_PREFIX/bin/gfortran" && ! -z "$GFORTRAN" ]] && ln -s "$GFORTRAN" "$BUILD_PREFIX/bin/gfortran"
echo "gfortran = $(which gfortran)"
echo "f2py = $(which f2py)"

./configure gfortran opt --prefix="$PREFIX" --with-pyoorb --with-f2py=f2py 
make
make install
