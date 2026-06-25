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

rp_module_id="openjk_jo"
rp_module_desc="openjk_jo - OpenJK: Jedi Outcast (SP)"
rp_module_licence="GPL2 https://raw.githubusercontent.com/JACoders/OpenJK/master/LICENSE.txt"
rp_module_help="Copy assets0.pk3  assets1.pk3  assets2.pk3  assets5.pk3 into $romdir/ports/jedioutcast"
rp_module_repo="git https://github.com/JACoders/OpenJK.git master"
rp_module_section="exp"
rp_module_flags=""

function _arch_openjk_jo() {
    # exact parsing from Makefile
    if isPlatform "rpi5"; then
        echo arm64
    else
        echo "$(uname -m | sed -e 's/i.86/x86/' | sed -e 's/^arm.*/arm/')"
   fi
}

function depends_openjk_jo() {
    getDepends cmake libjpeg-dev libpng-dev zlib1g-dev libsdl2-dev
}

function sources_openjk_jo() {
    gitPullOrClone
}

function build_openjk_jo() {
    mkdir -p "$md_build/build"
    cd "$md_build/build" || return 1
    cmake -DBuildJK2SPEngine=ON -DBuildJK2SPGame=ON -DBuildJK2SPRdVanilla=ON -DCMAKE_BUILD_TYPE=Release .. || return 1
    make clean
    make || return 1

    md_ret_require="$md_build/build/openjk_sp.$(_arch_openjk_jo)"
}

function install_openjk_jo() {
    md_ret_files=(
        "build/code/game/jagame$(_arch_openjk_jo).so"
        "build/code/rd-vanilla/rdjosp-vanilla_$(_arch_openjk_jo).so"
        "build/code/rd-vanilla/rdsp-vanilla_$(_arch_openjk_jo).so"
        "build/codeJK2/game/jospgame$(_arch_openjk_jo).so"
        "build/codemp/cgame/cgame$(_arch_openjk_jo).so"
        "build/codemp/game/jampgame$(_arch_openjk_jo).so"
        "build/codemp/rd-vanilla/rd-vanilla_$(_arch_openjk_jo).so"
        "build/codemp/ui/ui$(_arch_openjk_jo).so"
        "build/openjo_sp.$(_arch_openjk_jo)"
    )
}

function configure_openjk_jo() {
    local launcher_jo_sp="$md_inst/openjo_sp.$(_arch_openjk_jo)"
    local params=("+set com_jk2 1")
    isPlatform "mesa" && params+=("+set cl_renderer opengl1")
    isPlatform "kms" && params+=("+set r_mode -1" "+set r_customwidth %XRES%" "+set r_customheight %YRES%" "+set r_swapInterval 1")
    local script="$md_inst/launch-$md_id.sh"

    addPort "$md_id" "jedioutcast" "Star Wars - Jedi Knight - Jedi Outcast (SP)" "$script %ROM% ${params[*]}" "sp"
    moveConfigDir "$home/.local/share/openjo" "$md_conf_root/jedioutcast/openjo"

    [[ "$md_mode" == "remove" ]] && return

    mkRomDir "ports/jedioutcast"

    # link game data to install dir
    ln -snf "$romdir/ports/jedioutcast" "$md_inst/base"

    # dummy launch script to mirror openjk_ja and prep for future JO multiplayer
    cat > "$script" << _EOF_
#!/bin/bash
mode="\$1"
shift

case "\$mode" in
    sp) launcher="$launcher_jo_sp" ;;
esac

[[ -n "\$launcher" ]] && "\$launcher" "\$@"
_EOF_

    chmod +x "$script"
}