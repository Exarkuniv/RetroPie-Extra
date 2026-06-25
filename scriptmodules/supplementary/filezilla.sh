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

rp_module_id="filezilla"
rp_module_desc="A cross platform FTP application"
rp_module_licence="https://filezilla-project.org"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_filezilla() {
    getDepends xorg matchbox
}

function install_bin_filezilla() {
    aptInstall filezilla
}

function configure_filezilla() {
    mkRomDir "ports"
    mkdir -p "$md_inst"
    moveConfigDir "$home/.config/$md_id" "$md_conf_root/ports/$md_id"
    cat >"$md_inst/filezilla.sh" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager -use_titlebar no &
/usr/bin/filezilla
_EOF_
    chmod +x "$md_inst/filezilla.sh"

    addPort "$md_id" "filezilla" "FileZilla cross platform FTP application" "XINIT: $md_inst/filezilla.sh"
    mv "$md_conf_root/$md_id" "$md_conf_root/ports" || return 1
}