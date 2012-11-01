#!/bin/bash 
# SET SOME PATH VARIABLES
ROOT="/home/aditya/i9003"
# Toolchain path 
CROSS_COMPILE="/home/aditya/Toolchain/arm-eabi-linaro-4.6.2/bin/arm-eabi"
KERNEL_DIR="/home/aditya/i9003/GB"
RAMDISK_DIR="/home/aditya/i9003/ramdisk"
MODULES_DIR="$RAMDISK_DIR/lib/modules"
OUT="/home/aditya/i9003/out"
# Set correct base address as per device
BASE="81800000"

# DONE

echo "|~~~~~~~~COMPILING TITANIUM KERNEL ~~~~~~~~~~~|"
echo "|---------------------------------------------|"
echo "Cleaning source"
rm $OUT/normalboot.img
cd ../
rm *.lzma
cd $KERNEL_DIR 
export CROSS_COMPILE=$CROSS_COMPILE-
make -j clean mrproper
echo "Importing defconfig"
make -j debug_defconfig
echo "Please Enter Release Version" 
read $version 
echo $version > .version
echo ">> COMPILING!"
make -j84
echo "Copying modules and stripping em"
find -name '*.ko' -exec cp -av {} $MODULES_DIR/ \;


cd $MODULES_DIR
echo "Strip modules for size"

for m in $(find . | grep .ko | grep './')
do
        echo $m

/home/aditya/Toolchain/arm-eabi-linaro-4.6.2/bin/arm-eabi-strip --strip-unneeded $m
done


cd $KERNEL_DIR
echo "Packing Ramdisk"
cd $ROOT
./mkbootfs ramdisk | lzma > ramdisk.lzma
echo "Pack normalboot"
./mkbootimg --kernel $KERNEL_DIR/arch/arm/boot/zImage --ramdisk ramdisk.lzma --pagesize 1000 -o $OUT/normalboot.img 
cd $OUT
echo "Clear old tarballs"
rm *.tar

tar -cvf KERNEL.tar normalboot.img


echo "DONE, PRESS ENTER TO FINISH"
read ANS
 
