#!/usr/bin/env bash

# Installation scriptmodule for RetroPie. This file is a work-in-progress.
# For more information, please visit:
#
# https://github.com/RetroPie/RetroPie-Setup
# https://github.com/Exarkuniv/RetroPie-Extra
#
# See the LICENSE file distributed with this source and at
# https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
# https://raw.githubusercontent.com/Exarkuniv/RetroPie-Extra/master/LICENSE
#

rp_module_id="starcraft"
rp_module_desc="ARM recompiled exe of StarCraft"
rp_module_help="Thanks to PI Labs, Notaz, and Blizzard for release free this game in 2017.\n\nCopy an installed Starcraft or Starcraft with Brood War folder (v1.16.1) into $romdir/ports/Starcraft\n\nFrom the Starcraft CD or ISO, copy 'install.exe' and rename it 'StarCraft.mpq'\n\nFrom the Brood War CD or ISO (optional), copy 'install.exe' and rename it 'BroodWar.mpq'"
rp_module_repo="file https://notaz.gp2x.de/misc/starec/libscr.tar.xz"
rp_module_section="exp"
rp_module_flags="!all arm"

function depends_starcraft() {
    getDepends xorg wine matchbox
}

function install_bin_starcraft() {
    rmDirExists "$md_inst"
    mkdir -p "$md_inst"
    downloadAndExtract "$md_repo_url" "$md_inst"
}

function configure_starcraft() {
    local script="$md_inst/starcraftr.sh"
    addPort "$md_id" "starcraft" "Starcraft" "XINIT:$script"

    [[ "$md_mode" == "remove" ]] && return

    mkRomDir "ports/Starcraft"

    cat > "$script" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager -use_titlebar no &
cd "$md_inst"
LD_LIBRARY_PATH=. setarch linux32 -L wine libscr_sa_arm.exe.so
_EOF_
    chmod +x "$script"

    local file
    local rom_files=(
        'BrooDat.mpq'
        'BroodWar.mpq'
        'Local.dll'
        'patch_rt.mpq'
        'StarCraft.mpq'
        'StarDat.mpq'
        'maps'
    )
    for file in "${rom_files[@]}"; do
        ln -snf "$romdir/ports/Starcraft/$file" "$md_inst/$file"
    done

    local dir
    local conf_dirs=(
        'characters'
        'Errors'
        'save'
    )
    for dir in "${conf_dirs[@]}"; do
        mkUserDir "$md_conf_root/starcraft/$dir"
        ln -snf "$md_conf_root/starcraft/$dir" "$md_inst/$dir"
    done
}
