## SDL2 2.0.3 RASPBERRYPI

Automatable steps build SDL2 for the RaspberryPI

SDL2 is a cross platform grqphics library project located here:

 * https://www.libsdl.org/index.php

It is commonly refered to as "The gaming graphical framework API", but it is more than that.

This repository is a set of automatable scripts to build this library
for the RaspberryPI, taking advantage of the GPU accelerated graphics and OpenGLES.

The SDL2 built components are enumerated in the "settings" file, this should allow you
to use the library along with sound, True Type fonts, and networking.

There is a patch on the SDL2 core library to work out thumb-less cross compilers
and memory locking. You can find it in the "patches" directory.

### What you need

 * a 32-bit i686 system running Linux (Debian wheezy suggested).
 * qemu-arm-static and binfmt_tools installed and running.
 * a ARM chroot jail containing Raspbian. You can use debootstrap too.
 * a Cross compiler for the ARM architecture (Linaro recommended)
 * If you want to build the Debian packages, install the "devscripts" tools
 * An account with sudo privileges

### How to build

Create a Raspbian root file system:

 $ ./raspbian-rootfs /var/local/jails/arm-sdl2

Copy the file "bootstrap.sh" into your ARM jail and run it as root.
It will install all development software needed to build SDL2.

 $ sudo cp bootstrap.sh /var/local/jails/arm-sdl2/tmp
 $ sudo chroot /var/local/jails/arm-sdl2
 $ cd /tmp && ./bootstrap.sh
 $ exit

Back on the host system, make sure you have a cross toolchain installed.
I recommend Linaro because it is the only one I used on this setup. From your home directory:

 $ git clone --depth 1 https://github.com/raspberrypi/tools rpi-tools

Add the following at the end of your .bashrc then "source .bashrc":

 export PATH=$PATH:$HOME/rpi-tools

Executing "arm-linux-gnueabi-gcc -v" should give you a short version notice.

Open the "settings" file and make sure "sysroot" and "processors_count" match your system.
You can now start the build.

 $ ./xbuild.sh

If all goes well you should see a message "SDL2 libraries built and ready at".
It takes less than 3 minutes on a 4-CPU 2.5GHz, 1GB RAM system.

## How to install

You can create the 2 Debian packages (runtime and development files) like this:

 $ debuild -aarmhf -us -uc -b

If your host system is non-debian you can deploy the libraries manually, much easier:

 $ tar -zcf sdl2-raspberrypi.tgz sdl2-raspberrypi

On the RaspberryPI, as root:

 $ sudo tar zxf sdl2-raspberrypi.tgz -C /opt

In either case you need to add the libraries to your path. This allows to coexist
with SDL2 prior versions:

 $ export LD_LIBRARY_PATH=/opt/sdl2-raspberrypi/lib

That should be it - Enjoy!

This content is released under the (http://opensource.org/licenses/MIT) MIT License.
See the file LICENSE for details.

Albert Casals - skarbat@gmail.com
September, October 2014
