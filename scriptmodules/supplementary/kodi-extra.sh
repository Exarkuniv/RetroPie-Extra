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

rp_module_id="kodi-extra"
rp_module_desc="Kodi - Open source home theatre software"
rp_module_licence="GPL2 https://raw.githubusercontent.com/xbmc/xbmc/master/LICENSE.GPL"
rp_module_section="exp"
rp_module_flags="!mali"

function depends_kodi-extra() {
    if isPlatform "rpi"; then
        if [[ "$__depends_mode" == "install" ]]; then
            # Remove the old pipplware repository
            rm -f /etc/apt/sources.list.d/mene.list
            # Use the official Kodi repository
            echo "deb https://mirrors.kodi.tv/debian bookworm main" >/etc/apt/sources.list.d/kodi.list
            wget -qO - https://mirrors.kodi.tv/debian/repo.gpg.key | apt-key add - >/dev/null
        else
            rm -f /etc/apt/sources.list.d/kodi.list
            apt-key del 4096R/AC8F3A7D >/dev/null
        fi
    fi
}

function install_bin_kodi-extra() {
    aptInstall kodi kodi-peripheral-joystick
}

function remove_kodi-extra() {
    aptRemove kodi kodi-peripheral-joystick
    rm -f /etc/apt/sources.list.d/kodi.list
}

function configure_kodi-extra() {
    echo 'SUBSYSTEM=="input", GROUP="input", MODE="0660"' > /etc/udev/rules.d/99-input.rules

    mkRomDir "kodi"

    cat > "$romdir/kodi/Kodi.sh" << _EOF_
#!/bin/bash
/opt/retropie/supplementary/runcommand/runcommand.sh 0 "kodi-standalone" "kodi"
_EOF_

    chmod +x "$romdir/kodi/Kodi.sh"

    setESSystem 'Kodi' 'kodi' '~/RetroPie/roms/kodi' '.sh .SH' '%ROM%' 'pc' 'kodi'
}
