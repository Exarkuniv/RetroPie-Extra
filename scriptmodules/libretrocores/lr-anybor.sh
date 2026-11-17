#!/usr/bin/env bash

# This file is part of RetroPie-Extra, a supplement to RetroPie.
# For more information, please visit:
#
# https://github.com/RetroPie/RetroPie-Setup
# https://github.com/Exarkuniv/RetroPie-Extra
#
# See the LICENSE file distributed with this source and at
# https://raw.githubusercontent.com/Exarkuniv/RetroPie-Extra/master/LICENSE
#

rp_module_id="lr-anybor"
rp_module_desc="OpenBOR engine - AnyBOR libretro (historical engine profiles; 64-bit)"
rp_module_help="ROM Extensions: .pak .spk .zip .anybor\n\nCopy your games to $romdir/openbor. ZIP files must contain a single game or a unique .anybor descriptor. Genuine protected SPAK archives are not supported.\n\nRequires 64-bit Linux and RetroArch. The core includes engines under non-commercial terms; see LICENSES.md."
rp_module_licence="NONCOM https://github.com/retrodiv/AnyBOR-libretro/blob/main/LICENSES.md"
rp_module_repo="git https://github.com/retrodiv/AnyBOR-libretro.git main"
rp_module_section="exp"
rp_module_flags="!all 64bit"

function depends_lr-anybor() {
    if [[ "$(getconf LONG_BIT 2>/dev/null)" != "64" ]]; then
        md_ret_errors+=("AnyBOR requires a 64-bit userspace.")
        return 1
    fi
    case "$(uname -m)" in
        x86_64|aarch64|riscv64) ;;
        *)
            md_ret_errors+=("Unsupported architecture for AnyBOR: $(uname -m)")
            return 1
            ;;
    esac

    getDepends git make gcc g++ binutils python3
    if [[ "$(uname -m)" == "x86_64" ]]; then
        getDepends nasm
    fi
}

function sources_lr-anybor() {
    gitPullOrClone
}

function build_lr-anybor() {
    local jobs="${__jobs:-2}"
    local target output
    [[ "$jobs" =~ ^[1-9][0-9]*$ ]] || jobs=2

    # RetroPie's ASFLAGS may contain GCC options such as -march=native that
    # cannot be passed to NASM by libvpx's configure script.
    # Managed build mode avoids overwriting old, possibly root-owned
    # anybor_libretro.so files in the source directory.
    env -u ASFLAGS \
        NUMPROC="$jobs" \
        OBOR_BUILD_ROOT="$md_build/.build" \
        python3 tools/build.py --target auto --platform unix || return 1

    case "$(uname -m)" in
        x86_64) target="linux-x86_64" ;;
        aarch64) target="linux-aarch64" ;;
        riscv64) target="linux-riscv64" ;;
    esac
    output="$md_build/.build/dist/$target/anybor_libretro.so"
    if [[ ! -s "$output" ]]; then
        md_ret_errors+=("AnyBOR output missing or empty: $output")
        return 1
    fi

    # Keep the installed filename conventional for RetroPie libretro modules.
    rm -f "$md_build/anybor_libretro.so" || return 1
    install -m 0644 "$output" "$md_build/anybor_libretro.so" || return 1
    md_ret_require="$md_build/anybor_libretro.so"
}

function install_lr-anybor() {
    md_ret_files=(
        'anybor_libretro.so'
        'anybor_libretro.info'
        'LICENSE'
        'LICENSES.md'
        'LICENSES'
        'NOTICE.txt'
        'README.md'
    )
}

function configure_lr-anybor() {
    local info_dir="$configdir/all/retroarch/cores"

    # In removal mode addEmulator deletes our entry; addSystem then removes
    # the frontend system only if no other OpenBOR emulator remains.
    if [[ "$md_mode" == "remove" ]]; then
        addEmulator 1 "$md_id" "openbor" "$md_inst/anybor_libretro.so"
        addSystem "openbor" "OpenBOR" ".pak .spk .zip .anybor"
        rm -f "$info_dir/anybor_libretro.info"
        return
    fi

    mkRomDir "openbor"
    defaultRAConfig "openbor"

    # Use AnyBOR as default only when OpenBOR has no default yet.
    # RetroPie's addEmulator preserves an already selected default.
    addEmulator 1 "$md_id" "openbor" "$md_inst/anybor_libretro.so"
    addSystem "openbor" "OpenBOR" ".pak .spk .zip .anybor"

    mkUserDir "$info_dir"
    install -m 0644 "$md_inst/anybor_libretro.info" "$info_dir/anybor_libretro.info"
    chown "$__user:$__group" "$info_dir/anybor_libretro.info"
}
