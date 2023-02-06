#!/bin/bash

# If doing cross-compilation, we need to hack the f2py script to point to the right binary.
# This is a workaround for https://github.com/conda-forge/cross-python-feedstock/issues/64
if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]] && [[ `uname -s` == "Darwin" ]]; then
    shebang="#\!${BUILD_PREFIX}/venv/build/bin/python"
    f2py_executable=`which f2py`
    echo "Hacking shebang: " $shebang
    echo "Into: " $f2py_executable
    sed -i "1s%.*%$shebang%" $f2py_executable
fi

./configure gfortran opt --prefix="$PREFIX" --with-pyoorb
make
make install
