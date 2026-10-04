#!/usr/bin/env bash

set -e

KERNEL_DIR="$(pwd)"
OUT_DIR="${KERNEL_DIR}/out"
ANYKERNEL_DIR="${KERNEL_DIR}/anykernel"
CLANG_DIR="${KERNEL_DIR}/toolchain/clang"

export ARCH=arm64
export SUBARCH=arm64
export HEADER_ARCH=arm64

DEFCONFIG="vendor/holi-qgki_defconfig"
DEBUG_CONFIG="vendor/debugfs.config"

mkdir -p "${OUT_DIR}"
mkdir -p "${KERNEL_DIR}/toolchain"

if [ ! -f "${CLANG_DIR}/bin/clang" ]; then
    mkdir -p "${CLANG_DIR}"
    curl -sSL "https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/android13-release/clang-r450784d.tar.gz" | tar -xz -C "${CLANG_DIR}"
fi

export PATH="${CLANG_DIR}/bin:${PATH}"

export CC=clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-android-
export CROSS_COMPILE_COMPAT=arm-linux-androideabi-

if [ ! -f "${CLANG_DIR}/bin/aarch64-linux-android-elfedit" ]; then
    for tool in addr2line ar as elfedit ld ld.lld nm objcopy objdump ranlib readelf size strings strip; do
        if command -v "llvm-${tool}" >/dev/null 2>&1; then
            ln -sf "$(command -v "llvm-${tool}")" "${CLANG_DIR}/bin/aarch64-linux-android-${tool}"
            ln -sf "$(command -v "llvm-${tool}")" "${CLANG_DIR}/bin/arm-linux-androideabi-${tool}"
        elif command -v "${tool}" >/dev/null 2>&1; then
            ln -sf "$(command -v "${tool}")" "${CLANG_DIR}/bin/aarch64-linux-android-${tool}"
            ln -sf "$(command -v "${tool}")" "${CLANG_DIR}/bin/arm-linux-androideabi-${tool}"
        elif command -v "aarch64-linux-gnu-${tool}" >/dev/null 2>&1; then
            ln -sf "$(command -v "aarch64-linux-gnu-${tool}")" "${CLANG_DIR}/bin/aarch64-linux-android-${tool}"
            ln -sf "$(command -v "arm-linux-gnueabi-${tool}")" "${CLANG_DIR}/bin/arm-linux-androideabi-${tool}"
        fi
    done
    ln -sf ld.lld "${CLANG_DIR}/bin/aarch64-linux-android-ld"
    ln -sf ld.lld "${CLANG_DIR}/bin/arm-linux-androideabi-ld"
    ln -sf clang "${CLANG_DIR}/bin/aarch64-linux-android-gcc"
    ln -sf clang "${CLANG_DIR}/bin/arm-linux-androideabi-gcc"
fi

make -j"$(nproc)" \
    O="${OUT_DIR}" \
    ARCH=arm64 \
    CC=clang \
    LD=ld.lld \
    CLANG_TRIPLE="${CLANG_TRIPLE}" \
    CROSS_COMPILE="${CROSS_COMPILE}" \
    CROSS_COMPILE_COMPAT="${CROSS_COMPILE_COMPAT}" \
    "${DEFCONFIG}" "${DEBUG_CONFIG}"

make -j"$(nproc)" \
    O="${OUT_DIR}" \
    ARCH=arm64 \
    CC=clang \
    LD=ld.lld \
    CLANG_TRIPLE="${CLANG_TRIPLE}" \
    CROSS_COMPILE="${CROSS_COMPILE}" \
    CROSS_COMPILE_COMPAT="${CROSS_COMPILE_COMPAT}" \
    olddefconfig

make -j"$(nproc)" \
    O="${OUT_DIR}" \
    ARCH=arm64 \
    CC=clang \
    LD=ld.lld \
    CLANG_TRIPLE="${CLANG_TRIPLE}" \
    CROSS_COMPILE="${CROSS_COMPILE}" \
    CROSS_COMPILE_COMPAT="${CROSS_COMPILE_COMPAT}" \
    Image dtbs

if [ -f "${OUT_DIR}/arch/arm64/boot/Image" ]; then
    cp "${OUT_DIR}/arch/arm64/boot/Image" "${ANYKERNEL_DIR}/Image"

    if [ -f "${OUT_DIR}/arch/arm64/boot/dtbo.img" ]; then
        cp "${OUT_DIR}/arch/arm64/boot/dtbo.img" "${ANYKERNEL_DIR}/dtbo.img"
    fi

    find "${OUT_DIR}/arch/arm64/boot/dts" -name "*.dtb" -exec cp {} "${ANYKERNEL_DIR}/" \; 2>/dev/null || true

    ZIP_DATE="$(TZ='Asia/Kolkata' date +%Y%m%d-%H%M)"
    ZIP_NAME="Crest-Kernel-larry-${ZIP_DATE}.zip"

    cd "${ANYKERNEL_DIR}"
    zip -r9 "${KERNEL_DIR}/${ZIP_NAME}" * -x .git .gitignore "*.zip"
    cd "${KERNEL_DIR}"

    echo "Build package created: ${ZIP_NAME}"
fi
