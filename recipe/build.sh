#!/bin/bash

set -ex

build_numpy=$(${BUILD_PREFIX}/bin/python -c 'import site; print(site.getsitepackages()[0])')/numpy
host_numpy=$(${PREFIX}/bin/python -c 'import site; print(site.getsitepackages()[0])')/numpy

if [ -d "${build_numpy}" ]; then
  if [[ "${build_numpy}" != "${host_numpy}" ]]; then
    pushd "${build_numpy}/f2py/_backends"
    patch -b -p1 _meson.py < ${RECIPE_DIR}/f2py_meson.patch
    rm -rf __pycache__
    popd
  fi
fi

if [ -d "${host_numpy}" ]; then
  pushd "${host_numpy}/f2py/_backends"
  patch -b -p1 _meson.py < ${RECIPE_DIR}/f2py_meson.patch
  rm -rf __pycache__
  popd
fi

if [[ "${CONFIG}" == *_python3.12* ]]; then
  export MESON_ARGS=${MESON_ARGS//--prefix=${PREFIX}/""}
  if [[ "${build_platform}" != "${target_platform}" ]]; then
    export F2PY_MESON_CROSS_FILE=${BUILD_PREFIX}/meson_cross_file.txt
    echo "meson cross file contents:"
    cat ${F2PY_MESON_CROSS_FILE}
  fi
  export CONDA_LIBORB="pyoorb.pyf ../main/io.f90 ../python/*.f90 ../classes/*.f90 ../modules/*.f90 ${MESON_ARGS}"
  export FFLAGS="${FFLAGS} -I${SRC_DIR}/build"
  export CFLAGS="${CFLAGS} -I${SRC_DIR}/build"
else
  export CONDA_LIBORB="-m pyoorb pyoorb.o pyoorb.pyf ../lib/liboorb.a"
fi

./configure gfortran opt --prefix="${PREFIX}" --with-pyoorb \
  --with-f2py=$(which f2py) --with-python="${PYTHON}"
make || {
  cat $SRC_DIR/build/_pyoorb_build/bbdir/meson-logs/meson-log.txt
  exit 1
}
make install

if [ -d "${build_numpy}" ]; then
  if [[ "${build_numpy}" != "${host_numpy}" ]]; then
    pushd "${build_numpy}/f2py/_backends"
    mv _meson.py.orig _meson.py
    rm -rf __pycache__
    popd
  fi
fi

if [ -d "${host_numpy}" ]; then
  pushd "${host_numpy}/f2py/_backends"
  mv _meson.py.orig _meson.py
  rm -rf __pycache__
  popd
fi
