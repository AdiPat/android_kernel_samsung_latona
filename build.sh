<<<<<<< HEAD
#!/bin/bash 
#
# Kernel Build script for GT-I9003 Custom Titanium Kernel 
#
# Written by Aditya Patange aka Adi_Pat adithemagnificent@gmail.com 
#
# release defconfig (latona_galaxysl_defconfig) - Stripped debug stuff for faster Kernel
# debug defconfig (debug_defconfig) - Has debug Stuff enabled for testing purposes
#
# TO BUILD THE KERNEL- 
#
# Edit TOOLCHAIN path and RAMDISK path accordingly. 
#
# Make sure you have mkbootimg , mkbootfs binaries in $ROOT directory.
#
# ./build.sh release/debug .version-number (default is 0)
#
# EXAMPLE: ./build.sh release 10
# 
# 

## Misc Stuff ##

red='tput setaf 1'
green='tput setaf 2'
yellow='tput setaf 3'
blue='tput setaf 4'
violet='tput setaf 5'
cyan='tput setaf 6'
white='tput setaf 7'
normal='tput sgr0'
bold='setterm -bold'

### ### ### ### 


# SET SOME PATH VARIABLES
# Modify these as per requirements
ROOT="/home/aditya/i9003"
# Toolchain path = 
TOOLCHAIN="/home/aditya/Toolchain/arm-eabi-linaro-4.7.2/bin/arm-eabi"
KERNEL_DIR="/home/aditya/i9003/GB"
RAMDISK_DIR="/home/aditya/i9003/ramdisk"
MODULES_DIR="$RAMDISK_DIR/lib/modules"
OUT="/home/aditya/i9003/out"
# Device Specific flags
# Defconfigs
RELEASE_DEFCONFIG=latona_galaxysl_defconfig
DEBUG_DEFCONFIG=debug_defconfig
DEFCONFIG=latona_galaxysl_defconfig # Default
# Kernel addresses 
BASE="81800000"
PAGESIZE="4096"
# Kernel format
KERNEL=normalboot.img 

# More Misc stuff
echo $2 > VERSION
VERSION='cat VERSION'
clear
clear
clear
clear

###################### DONE ##########################
$cyan
echo "***********************************************"
echo "|~~~~~~~~COMPILING TITANIUM KERNEL ~~~~~~~~~~~|"
echo "|---------------------------------------------|"
$yello
echo "***********************************************"
echo "-----------------------------------------------"
$red
echo "---------- Adi_Pat @ XDA-DEVELOPERS -----------"
$yello
echo "-----------------------------------------------"
echo "***********************************************"
$normal

echo ">> Cleaning source"

# Clean old built kernel in out folder 
if [ -a $OUT/$KERNEL ]; then
rm $OUT/$KERNEL
fi

# Import Defconfig
cd $KERNEL_DIR 
export ARCH=arm CROSS_COMPILE=$TOOLCHAIN-
make -j clean mrproper
if [ $1 = "release" ]; then
echo "Importing RELEASE DEFCONFIG "
make -j $RELEASE_DEFCONFIG
elif [ $1 = "debug" ]; then 
echo "Importing DEBUG DEFCONFIG"
make -j $DEBUG_DEFCONFIG
else
echo "Importing $DEFCONFIG"
make -j $DEFCONFIG
fi

# Set Release Version 
if [ -n VERSION ]; then
echo "Release version is 0"
echo "0" > .version
else 
echo "Release version is $VERSION" 
echo $VERSION > .version
rm VERSION
fi

# Build Modules
$bold
echo ">> COMPILING!"
echo ">> Building Modules" 
$white
make -j modules
$normal
echo "Copying modules"
find -name '*.ko' -exec cp -av {} $MODULES_DIR/ \;

# Strip unneeded symbols
cd $MODULES_DIR
echo ">> Strip modules for size"
=======
# Make mrproper
echo "Cleaning Source"
echo "Building Config"

make clean mrproper -j1000

# Set config

make latona_debug_defconfig -j1000

echo "Edit build version"

read vrsn;

echo $vrsn > .version

# Make modules

echo "Compiling Modules and Kernel"

rm ../compile.log

make -j84 > ../compile.log 2>&1

echo "Copy modules"

find -name '*.ko' -exec cp -av {} ../tools/out/system/lib/modules/ \;

echo "Repacking the Kernel now"

cd ..

rm *.zip

echo "Packing Kernel"

rm tools/unpack/zImage
cp Kernel/arch/arm/boot/zImage tools/unpack/zImage

cd tools
rm out/boot.img

tools/mkbootimg --kernel unpack/zImage --ramdisk unpack/boot.img-ramdisk.gz -o out/boot.img --base 10000000

cd out

cd system/lib/modules

echo "Strip modules for size"
>>>>>>> 58eadb2... ARM: Add CMDLINE_EXTEND for UART, enable EARLY_PRINTK

for m in $(find . | grep .ko | grep './')
do echo $m
$TOOLCHAIN-strip --strip-unneeded $m
done

# Build zImage
$white
echo ">> Building zImage"
cd $KERNEL_DIR 
make -j84 zImage
$normal
if [ -a $KERNEL_DIR/arch/arm/boot/zImage ];
then
echo ">> Packing Ramdisk"
cd $ROOT
./mkbootfs ramdisk | lzma > ramdisk.lzma
echo ">> Pack normalboot"
./mkbootimg --kernel $KERNEL_DIR/arch/arm/boot/zImage --ramdisk ramdisk.lzma --pagesize 1000 -o $OUT/$KERNEL
cd $OUT
echo "Clear old tarballs"
rm *.tar
tar -cvf KERNEL.tar $KERNEL
$bold
$yellow
echo "Flashable $KERNEL in $OUT/$KERNEL"
echo "Flashable ODIN tarball at $OUT/KERNEL.tar"
# Remove files
rm $ROOT/ramdisk.lzma
$cyan
echo "DONE, PRESS ENTER TO FINISH"
$normal
read ANS
else
$red
echo "No compiled zImage at $KERNEL_DIR/arch/arm/boot/zImage"
echo "Compilation failed - Fix errors and recompile "
echo "Press enter to end script"
$normal
read ANS
fi
 
