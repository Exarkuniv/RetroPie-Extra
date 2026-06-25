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

rp_module_id="jfsw"
rp_module_desc="JFSW - Shadow Warrior source port by Jonathon Fowler"
rp_module_help="Place your registered version game files in $romdir/ports/shadowwarrior"
rp_module_licence="GPL https://github.com/jonof/jfsw/blob/master/GPL.TXT"
rp_module_repo="git https://github.com/jonof/jfsw.git master"
rp_module_section="exp"
rp_module_flags=""

function depends_jfsw() {
    getDepends libgl1-mesa-dev libsdl2-dev libvorbis-dev rename
}

function sources_jfsw() {
    gitPullOrClone
}

function build_jfsw() {
    make DATADIR="$romdir/ports/shadowwarrior" RELEASE=1 USE_POLYMOST=1 USE_OPENGL=USE_GLES2 WITHOUT_GTK=1 || return 1
    md_ret_require="$md_build/sw"
}

function install_jfsw() {
    md_ret_files='sw'
}

function gamedata_jfsw() {
    local dest="$romdir/ports/shadowwarrior"
    mkUserDir "$dest"
    pushd "$dest"
    rename 'y/A-Z/a-z/' *
    popd
    if [[ ! -f "$dest/sw.grp" ]]; then
        # download shareware data
        local tempdir="$(mktemp -d)"
        download ftp://ftp.3drealms.com/share/3dsw12.zip "$tempdir"
        unzip -Lo "$tempdir/3dsw12.zip" swsw12.shr -d "$tempdir" || return 1
        unzip -Lo "$tempdir/swsw12.shr" sw.grp sw.rts -d "$dest" || return 1
        rm -rf "$tempdir"
    fi
    chown -R $user:$user "$dest"
}

function configure_jfsw() {
    [[ "$md_mode" == "install" ]] && gamedata_jfsw
    addPort "$md_id" "sw" "Shadow Warrior source port" "$md_inst/sw %ROM%" ""
    local gamedir="$romdir/ports/shadowwarrior"
    [[ -f "$gamedir/dragon.zip" ]] && addPort "$md_id" "sw" "Shadow Warrior Twin Dragon" "$md_inst/sw %ROM%" "-gdragon.zip"
    [[ -f "$gamedir/wt.grp" ]] && addPort "$md_id" "sw" "Shadow Warrior Wanton Destruction" "$md_inst/sw %ROM%" "-gwt.grp"
    moveConfigDir "$home/.jfsw" "$md_conf_root/sw"
}