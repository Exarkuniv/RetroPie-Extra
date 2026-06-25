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

rp_module_id="dink"
rp_module_desc="FreeDink - Dink Smallwood Engine"
rp_module_licence="GPL3 http://git.savannah.gnu.org/cgit/freedink.git/plain/COPYING"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_dink() {
    getDepends  libvorbis-dev timgm6mb-soundfont
}

function install_bin_dink() {
    aptInstall freedink
}

function remove_dink() {
    aptRemove freedink
}

function configure_dink() {
    mkRomDir "$md_id"
    moveConfigDir "$home/.dink" "$md_conf_root/$md_id"
    addEmulator 1 "$md_id" "dink" "freedink -S -game %BASENAME%"
    addSystem "dink" "Free Dink - Dink Smallwood Engine" ".dsm .DSM"
    touch ${romdir}/${md_id}/dink.dsm
}

function gui_dink() {
    while true; do

        local cmd=(dialog --backtitle "$__backtitle"  --colors --cancel-label "Back" --help-button --no-collapse --cr-wrap --default-item "$default" --menu "   Dink Smallwood DMOD Manager\\n \\n" 22 60 12)
        local options=(1 "Install DMOD from dinknetwork.com")
             options+=(2 "Remove installed DMOD")

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            local default="$choice"

            case "$choice" in

                1)
                    _gui_dink_install
                    ;;

                2)
                    _gui_dink_uninstall
                    ;;
            esac
        else
            break
        fi
    done
}

function _gui_dink_install() {
    local search
    local folder

    search=$(dialog \
    --default-item "$default" \
    --backtitle "$__backtitle" \
    --title "Enter the name of the dmod to install" \
    --ok-label "Install" \
    --cancel-label "Back" \
    --form "" \
    22 76 16 \
    "    DMOD name:" 1 1 "" 1 22 76 100 \
    2>&1 >/dev/tty \
    )
    if [ -z "${search}" ]
    then
        return 0
    fi

    wget "http://www.dinknetwork.com/download/${search}.dmod" || return 1
    if ! [ -f ${search}.dmod ]
    then
        wget "http://www.dinknetwork.com/download/dmods/${search}.dmod" || return 1
    fi

    if [ -f ${search}.dmod ]
    then
        bzip2 -dk ${search}.dmod
        # A DMOD file is almost but not quite in zip/tar format. This step
        # converts the tar file into a format that can be expanded correctly.
        dd if=/dev/zero bs=412 count=2 >> ${search}.dmod.out
        tar -xvf ${search}.dmod.out || return 1

        # Need to remove the version from the folder name so that the correct
        # folder can be moved and the matching dsm file created.
        folder=${search%-*}
        sudo mv ${folder}/ /usr/share/games/dink
        touch ${romdir}/${md_id}/${folder}.dsm
        chown $user:$user "${romdir}/${md_id}/${folder}.dsm"

        rm "${search}.dmod.out"
        rm "${search}.dmod"
        printMsgs "dialog" "DMOD ${search}.dmod has been installed into /usr/share/games/dink/${folder}"
    else
        printMsgs "dialog" "Cannot find ${search}.dmod on dinknetwork.com"
    fi
}

function _gui_dink_uninstall() {
    local options=()
    local dmod
    local i=1

    while read dmod; do
        dmod=${dmod/\/usr\/share\/games\/dink\//}
        options+=($i "$dmod" OFF)
        ((i++))
    done < <(find -L "/usr/share/games/dink/" -mindepth 1 -maxdepth 1 -type d -not -empty | sort -u)

    if [[ ${#options[@]} -eq 0 ]] ; then
        printMsgs "dialog" "No DMODs were found in /usr/share/games/dink/."
        return
    fi

    local choices
    local cmd=(dialog --backtitle "$__backtitle" --ok-label "Remove" --cancel-label "Cancel" --checklist " Select DMODs to uninstall\n\n" 22 60 16) 

    choices=($("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty))

    # Exit if nothing was chosen or Cancel was used
    [[ ${#choices[@]} -eq 0 || $? -eq 1 ]] && return 1

    local deleted=""
    local count=0
    for choice in "${choices[@]}"; do
        choice="${options[choice*3-2]}"
        rmDirExists "/usr/share/games/dink/$choice"
        rm $romdir/$md_id/$choice.dsm
        deleted+=" $choice"
        count++
    done
    if [ "$count" eq "1" ]
    then
        printMsgs "dialog" "DMOD: $deleted has been removed"
    else
        printMsgs "dialog" "DMODs: $deleted have been removed"
    fi
}