export PATH="$HOME/caf/vendor/qcom/proprietary/llvm-arm-toolchain-ship/10.0/bin:$PATH"
GCCPATH="$HOME/caf/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin"
GCCPATH_32="$HOME/caf/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin"
SECONDS=0
ZIPNAME="QuicksilveRV2-ginkgo-$(date '+%Y%m%d-%H%M')-sdclang.zip"

mkdir -p out
make O=out ARCH=arm64 vendor/ginkgo-perf_defconfig

if [[ $1 == "-r" || $1 == "--regen" ]]; then
cp out/.config arch/arm64/configs/vendor/ginkgo-perf_defconfig
echo -e "\nRegened defconfig succesfully!"
exit 0
else
echo -e "\nStarting compilation...\n"
make -j$(nproc --all) O=out ARCH=arm64 CC=clang LD=ld.lld AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=$GCCPATH/aarch64-linux-androidkernel- CROSS_COMPILE_ARM32=$GCCPATH_32/arm-linux-androidkernel- Image.gz-dtb dtbo.img
fi

if [ -f "out/arch/arm64/boot/Image.gz-dtb" ] && [ -f "out/arch/arm64/boot/dtbo.img" ]; then
echo -e "\nKernel compiled succesfully! Zipping up...\n"
git clone -q https://github.com/ghostrider-reborn/AnyKernel3
cp out/arch/arm64/boot/Image.gz-dtb AnyKernel3
cp out/arch/arm64/boot/dtbo.img AnyKernel3
rm -f *zip
cd AnyKernel3
zip -r9 "../$ZIPNAME" * -x '*.git*' README.md *placeholder
cd ..
rm -rf AnyKernel3
echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
if command -v gdrive &> /dev/null; then
gdrive upload --share $ZIPNAME
else
echo "Zip: $ZIPNAME"
fi
rm -rf out/arch/arm64/boot
else
echo -e "\nCompilation failed!"
fi
