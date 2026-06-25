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

rp_module_id="lr-oberon"
rp_module_desc="Oberon RISC emulator for libretro"
rp_module_help="ROM Extensions: .dsk\n\nOberon RISC disk images are copied to $romdir/ports/oberon"
rp_module_licence="Unknown https://inf.ethz.ch/personal/wirth/ProjectOberon/license.txt"
rp_module_repo="git https://github.com/libretro/oberon-risc-emu master"
rp_module_section="exp"
rp_module_flags=""

function depends_lr-oberon() {
    getDepends build-essential libsdl2-dev
}

function sources_lr-oberon() {
    gitPullOrClone
}

function build_lr-oberon() {
    make -f Makefile.libretro clean || return 1
    make -f Makefile.libretro || return 1
    md_ret_require="$md_build/oberon_libretro.so"
}

function install_lr-oberon() {
    md_ret_files=(
        'oberon_libretro.so'
	'DiskImage/Oberon-2020-08-18.dsk'
        'README.md'
	'pcreceive.sh'
	'pcsend.sh'
    )
}

function configure_lr-oberon() {
    setConfigRoot "ports"

    mkRomDir "ports/oberon"

    cp -r "$md_inst/Oberon-2020-08-18.dsk" "$romdir/ports/oberon"
    chown -R $user:$user "$romdir/ports/oberon"

    addPort "$md_id" "oberon" "Oberon RISC" "$md_inst/oberon_libretro.so"
    local file="$romdir/ports/Oberon RISC.sh"
    cat >"$file" << _EOF_
#!/bin/bash
"$rootdir/supplementary/runcommand/runcommand.sh" 0 _PORT_ "oberon" "$romdir/ports/oberon/Oberon-2020-08-18.dsk"
_EOF_
    chown $user:$user "$file"
    chmod +x "$file"

    ensureSystemretroconfig "ports/oberon"
}