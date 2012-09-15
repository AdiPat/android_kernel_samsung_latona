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

for m in $(find . | grep .ko | grep './')
do
        echo $m

/home/aditya/Toolchain/arm-eabi-4.4.3/bin/arm-eabi-strip --strip-unneeded $m
done

cd ../../../

rm *.zip

zip -r BETA_KERNEL#$vrsn.zip META-INF system boot.img

cp BETA_KERNEL#$vrsn.zip ../../BETA_KERNEL#$vrsn.zip

echo "Done"

