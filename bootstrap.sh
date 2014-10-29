#!/bin/bash
#
# bootstrap.sh to build SDL2 for the RaspberryPI
#
# Install dependencies for building SDL2
# You need to run this script in a ARMv6 chroot jail or the RaspberryPI itself
# with root permissions
#
# This content is released under the (http://opensource.org/licenses/MIT) MIT License.
# See the file LICENSE for details.
#

PKGS="libudev-dev libasound2-dev libdbus-1-dev libraspberrypi0 libraspberrypi-bin libraspberrypi-dev
libx11-dev libxext-dev libxrandr-dev libfreetype6-dev libjpeg62-dev libtiff5-dev libwebp-dev
libxcursor-dev libxi-dev libxinerama-dev libxxf86vm-dev libxss-dev dh-autoreconf libpulse-dev libpng12-dev"

if [[ `uname -m` != armv* ]]; then
    echo "This is not an ARM system, you must run it within the chroot jail."
    exit 1
fi

if [ `id -u` != "0" ]; then
    echo "You need root permissions to run this script"
    exit 1
fi

echo "Installing SDL2 build dependencies"
apt-get install -y $PKGS

if [ "$?" == "0" ]; then
    touch ".bootstrapped"
fi

echo "Done!"
