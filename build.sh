#!/bin/bash -x
CYANOGENMOD=../../..

# Make mrproper
make clean mrproper

# Set config
make latona_galaxysl_defconfig

# Make modules
make -j8

# Copy modules
find -name '*.ko' -exec cp -av {} ../tools/out/system/lib/modules/ \;

./repack.sh 

