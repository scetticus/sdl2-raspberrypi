#!/bin/bash
#
#  xbuild.sh - Script to build all SDL2 libraries using a cross compiler
#
#  Please read through the README file on this same directory before using xbuild.
#
#  Once your environment is setup, executing "xbuild.sh" will build everything.
#
# This content is released under the (http://opensource.org/licenses/MIT) MIT License.
# See the file LICENSE for details.
#

set -e

source ./settings

curdir=`pwd`

# unbind from the ARM jail
function finish {
    sudo umount $buildroot
}
trap finish EXIT

# Minimal settings validation
if [ -z "$sysroot" ]; then
    echo "Where is your ARM root jail?"
    exit 1
fi

if [ ! -d "$sysroot" ] || [ ! -d "$sysroot/home" ] || [ ! -d "$sysroot/tmp" ]; then
    echo "does not look like $sysroot is an ARM jail, stop."
    exit 1
else
    echo "$sysroot looks like an ARM jail, good!"
fi

if [ ! -d "$rpitools" ]; then
    echo "Could not find cross compiler at $rpitools"
    echo "You might want to do: 'sudo git clone --depth 1 https://github.com/raspberrypi/tools $rpitools'. stop"
    exit 1
fi

if [ ! -f "$sysroot/tmp/xbuild/bootstrap.sh" ]; then
    echo "Mounting build directory..."
    sudo mkdir -p "$sysroot/tmp/xbuild"
    sudo mount --bind $curdir $sysroot/tmp/xbuild
fi

echo "Mounted directory where the builder can access the ARM jail: $sysroot/tmp/xbuild"

echo "Fixing symbolic link to LIBDL.so shared object"
target=$sysroot/usr/lib/arm-linux-gnueabihf/libdl.so
source=$sysroot/lib/arm-linux-gnueabihf/libdl.so.2
sudo rm -fv $target
sudo ln -sv $source $target

echo "Starting the build..."
tstart=`date +%s%N`

# Force the compiler be to a cross toolchain
export LDFLAGS="-L$rpi_firmwarelibs"
export CC="$kompiler --sysroot=$sysroot -I$rpi_firmwareincs -I$sysroot/usr/include -I$rpi_firmwareincs/interface/vcos/pthreads -I$rpi_firmwareincs/interface/vmcs_host/linux"

# Building the SDL2 core library
sdl2_base=`basename $SDL2 .tar.gz`
if [ ! -d $sdl2_base ]; then
    echo "Downloading SDL2 sources"
    rm -rf $sdl_base
    curl -L $SDL2 | tar zxf -

    # apply RaspberryPI source code patches
    patch -p0 < patches/sdl2-rpi.patch

    pushd $sdl2_base
    ./configure $sdl_configure_flags
    make -j $processors_count
    make install
    popd
else
    echo "SDL2 sources found, proceeding"
fi

# Expose the bare SDL2 and RaspberryPI firmware libraries for subsequent package dependencies
export LD_LIBRARY_PATH="$rpi_firmwarelibs"
export LDFLAGS="-Wl,-rpath -Wl,$rpi_firmwarelibs"
export CC="$kompiler --sysroot=$sysroot -I$rpi_firmwareincs -I$sysroot/usr/include -I$rpi_firmwareincs/interface/vcos/pthreads -I$rpi_firmwareincs/interface/vmcs_host/linux -I$install_at/include/\
SDL2"

sdl2_image_base=`basename $SDL2_image .tar.gz`
if [ ! -d $sdl2_image_base ]; then
    echo "building SDL2_image-2.0.0..."
    curl -L $SDL2_image | tar zxf -
    pushd  $sdl2_image_base
    ./configure $generic_configure_flags
    make -j $processors_count
    make install
    popd
fi

# True Type font library is a bit tricky
export LD_LIBRARY_PATH="$rpi_firmwarelibs"
export LDFLAGS="-Wl,-rpath -Wl,$rpi_firmwarelibs"

export CC="$kompiler --sysroot=$sysroot -I$rpi_firmwareincs -I$sysroot/usr/include -I$rpi_firmwareincs/interface/vcos/pthreads -I$rpi_firmwareincs/interface/vmcs_host/linux -I$sysroot/usr/include/freetype2 -I$install_at/include/SDL2"

sdl2_ttf_base=`basename $SDL2_ttf .tar.gz`
if [ ! -d  $sdl2_ttf_base ]; then
    echo "building SDL2_ttf-2.0.12..."
    curl -L $SDL2_ttf | tar zxf -
    pushd  $sdl2_ttf_base
    ./configure $generic_configure_flags -with-freetype-prefix=$sysroot/usr --x-includes=$sysroot/usr/include --x-libraries=$sysroot/usr/lib
    make -j $processors_count
    make install
    popd
fi

sdl2_mixer_base=`basename $SDL2_mixer .tar.gz`
if [ ! -d $sdl2_mixer_base ]; then
    curl -L $SDL2_mixer | tar zxf -
    pushd  $sdl2_mixer_base
    ./configure $generic_configure_flags
    make -j $processors_count
    make install
    popd
fi

sdl2_net_base=`basename $SDL2_net .tar.gz`
if [ ! -d $sdl2_net_base ]; then
    curl -L $SDL2_net | tar zxf -
    pushd  $sdl2_net_base
    ./configure $generic_configure_flags
    make -j $processors_count
    make install
    popd
fi

# Compute timing efforts
tend=`date +%s%N`
elapsed=`echo "scale=8; ($tend - $tstart) / 1000000000" | bc`
echo ""
echo "SDL2 libraries built and ready at: $install_basename in $elapsed seconds."
exit 0
