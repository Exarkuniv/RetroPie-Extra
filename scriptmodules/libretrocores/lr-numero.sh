#!/usr/bin/env bash

# This file is part of RetroPie-Extra, a supplement to RetroPie.
# For more information, please visit:
#
# https://github.com/RetroPie/RetroPie-Setup
# https://github.com/Exarkuniv/RetroPie-Extra
# https://github.com/RapidEdwin08/RetroPie-Setup
#
# See the LICENSE file distributed with this source and at
# https://raw.githubusercontent.com/RapidEdwin08/RetroPie-Setup/master/ext/RetroPie-Extra/LICENSE
#
# If no user is specified (for RetroPie below v4.8.9)
if [[ -z "$__user" ]]; then __user="$SUDO_USER"; [[ -z "$__user" ]] && __user="$(id -un)"; fi

rp_module_id="lr-numero"
rp_module_desc="lr-numero - Numero is a libretro core for emulating the TI-83 family of graphing calculators."
rp_module_help="ROM Extensions: .8xp .8xk .8xg\n\nPlace TI-83 ROMs in: $romdir/ti83/\n\nPlace TI-83 BIOS in: $biosdir/\nti83se.rom      TI-83 Silver Edition   *Recommended*\nti83plus.rom    TI-83 Plus\nti83.rom        TI-83\n\n{RESET/RESTART in RetroArch to CLEAR the Entire Memory}\n\nMore Info:\ngithub.com/nbarkhina/numero/blob/master/README.md\n\n{ti83se.rom}:\nhttps://web.archive.org/web/20230208002249/http://tiroms.weebly.com/uploads/1/1/0/5/110560031/ti83se.rom\n\n{ti83plus.rom}\nhttps://web.archive.org/web/20230208002249/http://tiroms.weebly.com/uploads/1/1/0/5/110560031/ti83plus.rom"
rp_module_repo="git https://github.com/nbarkhina/numero.git master"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-numero() {
    gitPullOrClone
}

function build_lr-numero() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="$md_build/numero_libretro.so"
}

function install_lr-numero() {
    md_ret_files=(
        'LICENSE'
        'numero_libretro.so'
    )
}

function game_data_lr-numero() {
    if [[ ! -f "$romdir/ti83/TIDOOM.8XG" ]]; then
        # Get Numero Assets: TI DooM, media, and gamelist.xml
        downloadAndExtract "https://raw.githubusercontent.com/RapidEdwin08/RetroPie-Setup-Assets/main/libretrocores/numero-rp-assets.tar.gz" "$romdir/ti83"
        if [[ ! -f "$romdir/ti83/gamelist.xml" ]]; then mv "$romdir/ti83/gamelist.xml.ti83" "$romdir/ti83/gamelist.xml"; fi
        chown -R $__user:$__user "$romdir/ti83"
    fi
    # Extra Systems for carbon-2021: cdimono1 cd-i cloud doom godot-engine j2me jaguarcd openbor ti83 wine
    if [[ ! -f "/etc/emulationstation/themes/carbon-2021/art/systems/ti83.svg" ]] && [[ -d "/etc/emulationstation/themes/carbon-2021" ]]; then
        downloadAndExtract "https://raw.githubusercontent.com/RapidEdwin08/RetroPie-Setup-Assets/main/supplementary/emulationstation-es-x-rp-assets.tar.gz" "/etc/emulationstation/themes"
    fi
}

function game_bios_lr-numero() {
    if [[ "$1"  == 'ti83se' ]]; then
        download https://web.archive.org/web/20230208002249/http://tiroms.weebly.com/uploads/1/1/0/5/110560031/ti83se.rom "/home/$__user/RetroPie/BIOS"
        chown $__user:$__user "/home/$__user/RetroPie/BIOS/ti83se.rom"
    fi
    if [[ "$1"  == 'ti83plus' ]]; then
        download https://web.archive.org/web/20230208002249/http://tiroms.weebly.com/uploads/1/1/0/5/110560031/ti83plus.rom "/home/$__user/RetroPie/BIOS"
        chown $__user:$__user "/home/$__user/RetroPie/BIOS/ti83plus.rom"
    fi
    dialog --no-collapse --title "Finished" --ok-label Back --msgbox "[../RetroPie/BIOS]:\n$(ls /home/$__user/RetroPie/BIOS | grep ti83 )"  25 75
}

function gui_lr-numero() {
    choice=$(dialog --title "[$md_id] Configuration Options" --menu "Attempt to Download TI-83 BIOS File(s)\n\nSee [Package Help] for Details\n\n[../RetroPie/BIOS]:\n$(ls /home/$__user/RetroPie/BIOS | grep ti83 )" 15 60 5 \
        "1" "{ti83se.rom}   TI-83 Silver Edition *Recommended*" \
        "2" "{ti83plus.rom} TI-83 Plus" \
        "3" "Cancel" 2>&1 >/dev/tty)

    case $choice in
        1)
            game_bios_lr-numero ti83se
            ;;
        2)
            game_bios_lr-numero ti83plus
            ;;
        3)
            echo "Canceled"
            ;;
        *)
            echo "Invalid Selection"
            ;;
    esac
}

function configure_lr-numero() {
    mkRomDir "ti83"
    ensureSystemretroconfig "ti83"

    addEmulator 1 "$md_id" "ti83" "$md_inst/numero_libretro.so"
    addSystem "ti83" "TI-83" ".8xp .8xk .8xg"

    [[ "$md_mode" == "install" ]] && game_data_lr-numero
}
