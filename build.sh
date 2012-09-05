# Make mrproper
echo "Cleaning Source"

make clean mrproper

# Set config

echo "Building Config"

make titanium_defconfig

# Make modules

echo "Compiling Modules"

make -j8

# Copy modules
find -name '*.ko' -exec cp -av {} ../tools/out/system/lib/modules/ \;

echo "Repacking the Kernel now"

cd ..

./repack.sh 

