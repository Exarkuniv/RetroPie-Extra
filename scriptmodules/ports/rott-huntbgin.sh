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

rp_module_id="rott-huntbgin"
rp_module_desc="ROTT - Rise of the Triad - The Hunt Begins (Shareware)"
rp_module_licence="GPL2 https://raw.githubusercontent.com/LTCHIPS/rottexpr/master/LICENSE.DOC"
rp_module_help=
rp_module_repo="git https://github.com/LTCHIPS/rottexpr.git master"
rp_module_section="exp"
rp_module_flags=""

function depends_rott-huntbgin() {

    local depends=(autotools-dev libsdl2-mixer-dev libopusfile0 libsdl2-mixer-2.0-0 libsdl2-ttf-dev xorg matchbox-window-manager x11-xserver-utils  libfluidsynth-dev fluidsynth fluid-soundfont-gs fluid-soundfont-gm)

	    isPlatform "64bit" && depends+=(libfluidsynth3)
        isPlatform "32bit" && depends+=(libfluidsynth1)

	getDepends "${depends[@]}"
}

function sources_rott-huntbgin() {
    gitPullOrClone
}

function build_rott-huntbgin() {
    sed -i 's#joystickenabled  = 0#joystickenabled  = 1#' "$md_build/src/rt_cfg.c"
    sed -i 's#joypadenabled    = 0#joypadenabled    = 1#' "$md_build/src/rt_cfg.c"
    sed -i 's/SHAREWARE   ?= 0/SHAREWARE   ?= 1/g' "$md_build/src/Makefile"
    cd src || return 1
    make rott || return 1
    md_ret_require=(
        "$md_build/src/rott"
    )
}

function install_rott-huntbgin() {
   md_ret_files=(
          'src/rott'
    )
}

function game_data_rott-huntbgin() {
    if [[ ! -f "$romdir/ports/rott/HUNTBGIN.WAD" ]]; then
        downloadAndExtract "https://github.com/Exarkuniv/game-data/raw/main/HUNTBGIN.zip" "$romdir/ports/rott"
    mv "$romdir/ports/rott/HUNTBGIN/"* "$romdir/ports/rott/" || return 1
    rmdir "$romdir/ports/rott/HUNTBGIN/"
    chown -R $user:$user "$romdir/ports/rott"
    fi

    chown -R $user:$user "$romdir/ports/rott"
}

function configure_rott-huntbgin() {
    local script="$md_inst/$md_id.sh"
    mkRomDir "ports"
    mkRomDir "ports/rott"
    moveConfigDir "$home/.rott" "$md_conf_root/rott"
	#create buffer script for launch
 cat > "$script" << _EOF_
#!/bin/bash
pushd "$romdir/ports/rott"
"$md_inst/rott" \$*
popd
_EOF_
    
	chmod +x "$script"
    addPort "$md_id" "rott-huntbgin" "Rise Of The Triad - The Hunt Begins (Shareware)" "$script"

    [[ "$md_mode" == "install" ]] && game_data_rott-huntbgin
}