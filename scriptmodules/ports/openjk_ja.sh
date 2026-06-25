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

rp_module_id="openjk_ja"
rp_module_desc="openjk_ja - OpenJK: JediAcademy (SP + MP)"
rp_module_licence="GPL2 https://raw.githubusercontent.com/JACoders/OpenJK/master/LICENSE.txt"
rp_module_help="Copy assets0.pk3, assets1.pk3, assets2.pk3, and assets3.pk3 into $romdir/ports/jediacademy/"
rp_module_repo="git https://github.com/JACoders/OpenJK.git master"
rp_module_section="exp"
rp_module_flags=""

function _arch_openjk_ja() {
        # exact parsing from Makefile
    if isPlatform "rpi5"; then
        echo arm64
    else
        echo "$(uname -m | sed -e 's/i.86/x86/' | sed -e 's/^arm.*/arm/')"
   fi
}

function depends_openjk_ja() {
    getDepends cmake libjpeg-dev libpng-dev zlib1g-dev libsdl2-dev
}

function sources_openjk_ja() {
    gitPullOrClone
}

function build_openjk_ja() {
    mkdir -p "$md_build/build"
    cd "$md_build/build" || return 1
    cmake -DCMAKE_BUILD_TYPE=Release .. || return 1
    make clean
    make || return 1

    md_ret_require=(
        "$md_build/build/openjk.$(_arch_openjk_ja)"
    )
}

function install_openjk_ja() {
    mkdir -p "$md_inst/base"

    local lib
    for lib in game/jampgame cgame/cgame ui/ui; do
        cp -v "$md_build/build/codemp/$lib$(_arch_openjk_ja).so" "$md_inst/base"
    done

    md_ret_files=(
        "build/openjkded.$(_arch_openjk_ja)"
        "build/openjk_sp.$(_arch_openjk_ja)"
        "build/openjk.$(_arch_openjk_ja)"
        "build/code/game/jagame$(_arch_openjk_ja).so"
        "build/code/rd-vanilla/rdsp-vanilla_$(_arch_openjk_ja).so"
        "build/codemp/rd-vanilla/rd-vanilla_$(_arch_openjk_ja).so"
    )
}

function configure_openjk_ja() {
    local launcher_sp="$md_inst/openjk_sp.$(_arch_openjk_ja)"
    local launcher_mp="$md_inst/openjk.$(_arch_openjk_ja)"
    local params=()
    isPlatform "mesa" && params+=("+set cl_renderer opengl1")
    isPlatform "kms" && params+=("+set r_mode -1" "+set r_customwidth %XRES%" "+set r_customheight %YRES%" "+set r_swapInterval 1")
    local script="$md_inst/launch-$md_id.sh"

    addPort "$md_id" "jediacademy" "Star Wars - Jedi Knight - Jedi Academy (SP)" "$script %ROM% ${params[*]}" "sp"
    addPort "$md_id" "jediacademy" "Star Wars - Jedi Knight - Jedi Academy (MP)" "$script %ROM% ${params[*]}" "mp"

    moveConfigDir "$home/.local/share/openjk" "$md_conf_root/jediacademy/openjk"

    [[ "$md_mode" == "remove" ]] && return

    mkRomDir "ports/jediacademy"

    # softlink game files to base dir
    local num
    for num in {0..3}; do
        ln -sf "$romdir/ports/jediacademy/assets$num.pk3" "$md_inst/base/assets$num.pk3"
    done

    cat > "$script" << _EOF_
#!/bin/bash
mode="\$1"
shift

case "\$mode" in
    sp) launcher="$launcher_sp" ;;
    mp) launcher="$launcher_mp" ;;
esac

[[ -n "\$launcher" ]] && "\$launcher" "\$@"
_EOF_

    chmod +x "$script"
}