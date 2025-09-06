#!/bin/bash

set -ex

# these bits of bash patch f2py in numpy to use the meson --cross-file
# when cross-compiling with meson on python 3.12 or higher
# see https://github.com/numpy/numpy/issues/28352
echo "BUILD_PREFIX: ${BUILD_PREFIX//p/P}"
echo "PREFIX: ${PREFIX//p/P}"
echo "CONDA_PREFIX: ${CONDA_PREFIX//p/P}"

build_numpy=${BUILD_PREFIX}/lib/python$(${BUILD_PREFIX}/bin/python -c "import sys; print('.'.join(sys.version.split('.')[0:2]))")/site-packages/numpy
if [[ "${build_platform}" != "${target_platform}" ]]; then
  build_venv_numpy=${BUILD_PREFIX}/venv/lib/python$(${BUILD_PREFIX}/venv/bin/build-python -c "import sys; print('.'.join(sys.version.split('.')[0:2]))")/site-packages/numpy
else
  build_venv_numpy=""
fi
host_numpy=${PREFIX}/lib/python$(${PREFIX}/bin/python -c "import sys; print('.'.join(sys.version.split('.')[0:2]))")/site-packages/numpy

echo "build_numpy: ${build_numpy}"
echo "build_venv_numpy: ${build_venv_numpy}"
echo "host_numpy: ${host_numpy}"

for npdir in ${build_numpy} ${build_venv_numpy} ${host_numpy}; do
  if [ -d "${npdir}/f2py/_backends" ]; then
    pushd "${npdir}/f2py/_backends"
    if [ ! -f _meson.py.orig ]; then
      echo "patched numpy at ${npdir}"
      patch -b -p1 _meson.py < ${RECIPE_DIR}/f2py_meson.patch
      rm -rf __pycache__
    fi
    popd
  fi
done

# on python 3.12 and higher, we have to use meson to build
if [[ "${CONFIG}" != *python3.10* ]] && [[ "${CONFIG}" != *python3.11* ]]; then
  # here we setup the cross-compiled builds with meson if needed
  if [[ "${build_platform}" != "${target_platform}" ]]; then
    export F2PY_MESON_CROSS_FILE=${BUILD_PREFIX}/meson_cross_file.txt
    echo "meson cross file contents:"
    cat ${F2PY_MESON_CROSS_FILE}
  fi
  # meson does not appear to like having .o or .a files directly passed to f2py
  # so we pass all of the f90 sources instead
  # we use single quotes to prevent the shell from expanding LIBSOURCES
  # until the build is running
  export CONDA_LIBORB='pyoorb.pyf ../python/*.f90 ${LIBSOURCES}'
  # these includes are needed to get the mod files
  export FFLAGS="${FFLAGS} -I${SRC_DIR}/build"
  export CFLAGS="${CFLAGS} -I${SRC_DIR}/build"
else
  export CONDA_LIBORB="-m pyoorb pyoorb.o pyoorb.pyf ../lib/liboorb.a"
fi

./configure gfortran opt --prefix="${PREFIX}" --with-pyoorb \
  --with-f2py=$(which f2py) --with-python="${PYTHON}"
make || {
  if [ -f $SRC_DIR/build/_pyoorb_build/bbdir/meson-logs/meson-log.txt ]; then
    echo "meson logs:"
    cat $SRC_DIR/build/_pyoorb_build/bbdir/meson-logs/meson-log.txt
  fi
  exit 1
}
make install

# now we undo the f2py patch
for npdir in ${build_numpy} ${build_venv_numpy} ${host_numpy}; do
  if [ -d "${npdir}/f2py/_backends" ]; then
    pushd "${npdir}/f2py/_backends"
    if [ -f _meson.py.orig ]; then
      echo "restored numpy at ${npdir}"
      mv _meson.py.orig _meson.py
      rm -rf __pycache__
    fi
    popd
  fi
done
