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

rp_module_id="roguecollection"
rp_module_desc="Retro Rogue Collection - six classic versions of Rogue in one package"
rp_module_help="A keyboard is required to play. Six versions of Rogue are included: PC Rogue 1.48, PC Rogue 1.1, Unix Rogue 5.4.2, Unix Rogue 5.3, Unix Rogue 5.2.1 and Unix Rogue 3.6.3. Saved games and the rogue.opt options file are kept in $md_inst."
rp_module_licence="GPL3 https://raw.githubusercontent.com/mikeyk730/Rogue-Collection/main/src/RogueCollectionQml/gpl-3.0.txt"
rp_module_repo="git https://github.com/mikeyk730/Rogue-Collection.git main"
rp_module_section="exp"
rp_module_flags="!all rpi4 rpi5 x86"

function depends_roguecollection() {
    getDepends xorg matchbox-window-manager qtbase5-dev qtdeclarative5-dev qtmultimedia5-dev \
        libqt5multimedia5-plugins qml-module-qtquick2 qml-module-qtquick-controls \
        qml-module-qtquick-dialogs qml-module-qtquick-layouts qml-module-qtquick-window2 \
        qml-module-qtmultimedia qml-module-qtgraphicaleffects
}

function sources_roguecollection() {
    gitPullOrClone

    # 'unix' is a predefined macro on linux, and the old C sources rely on common symbols
    sed -i "s/^CFLAGS   = /CFLAGS   = -Uunix /" "$md_build/src/MyCurses/makefile" \
        "$md_build/src/Rogomatic/makefile" "$md_build/src/Shared/Frontend/makefile" \
        "$md_build/src/RogueVersions/"*/makefile
    sed -i "s/^CFLAGS   = -Uunix -w /CFLAGS   = -Uunix -w -fcommon /" \
        "$md_build/src/Rogomatic/makefile" "$md_build/src/RogueVersions/"*/makefile

    # deprecated Qt api is used, which is fatal with -Werror
    sed -i "s/-Wall -Werror -pedantic/-Wall -pedantic -Wno-deprecated-declarations/" \
        "$md_build/src/RogueCollectionQml/"*/*.pro
}

function build_roguecollection() {
    cd "$md_build/src"
    make

    md_ret_require=(
        "$md_build/build/release/rogue-collection"
        "$md_build/build/release/retro-rogue-collection"
    )
}

function install_roguecollection() {
    cp -R "$md_build/build/release/." "$md_inst"
    rm -f "$md_inst/"*.a
}

function configure_roguecollection() {
    mkRomDir "ports"

    local script="$md_inst/$md_id.sh"
    cat > "$script" << _EOF_
#!/bin/bash
# the game libraries, graphics and options file are loaded from the working directory
pushd "$md_inst" >/dev/null
"$md_inst/\$1"
popd >/dev/null
_EOF_
    chmod +x "$script"

    addPort "$md_id" "roguecollection" "Rogue Collection" "XINIT:$script rogue-collection"
    addPort "$md_id" "retroroguecollection" "Retro Rogue Collection" "XINIT:$script retro-rogue-collection"

    [[ "$md_mode" == "install" ]] && chown -R "$user:$user" "$md_inst"
}
