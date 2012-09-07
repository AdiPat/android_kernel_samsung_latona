# Make mrproper
echo "Cleaning Source"

make clean mrproper

# Set config

echo "Building Config"

make test_defconfig

echo "Edit build version"

read vrsn;

echo $vrsn > .version

# Make modules

echo "Compiling Modules"

make -j8

# Copy modules
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

rm *.zip

zip -r Titanium-Kernel#$vrsn.zip META-INF system boot.img

cp Titanium-Kernel#$vrsn.zip ../../Titanium-Kernel$vrsn.zip

echo "Done"

