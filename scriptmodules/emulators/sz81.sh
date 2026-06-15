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


rp_module_id="sz81"
rp_module_desc="Sinclair ZX81 emulator"
rp_module_help="ROM Extensions: .o .p .81\n\nCopy your ZX81 roms to $romdir/zx81\n\n
    Exit          - Exit emulator (F10)\n
    Reset         - Reset emulator (F12)\n\n
Read the README files for more information\n
    
"
rp_module_licence="GPL2 https://github.com/SegHaxx/sz81/blob/main/README"
rp_module_repo="git https://github.com/SegHaxx/sz81.git main"
rp_module_section="exp"

function sources_sz81() {
    gitPullOrClone
}

function build_sz81() {
    make clean
    make
    md_ret_require="$md_build/sz81"
}

function install_sz81() {
    md_ret_files=(
        "."
    )
}

function configure_sz81() {
    mkRomDir "zx81"
    defaultRAConfig "zx81"

    addEmulator 1 "$md_id" "zx81" "XINIT:pushd $md_inst; $md_inst/sz81 -f %ROM%; popd"
    addEmulator 0 "${md_id}hero" "zx81" "XINIT:pushd $md_inst; $md_inst/sz81 -f -b %ROM%; popd"
    addSystem "zx81" "ZX81" ".o .p .81"
}
