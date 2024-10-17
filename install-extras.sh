#!/bin/bash

# Installation utility for RetroPie-Extra
#
# This file is part of RetroPie-Extra, a supplement to RetroPie.
# For more information, please visit:
#
# https://github.com/RetroPie/RetroPie-Setup
# https://github.com/Exarkuniv/RetroPie-Extra
#
# See the LICENSE file distributed with this source and at
# https://raw.githubusercontent.com/Exarkuniv/RetroPie-Extra/master/LICENSE
#

function runHelp() {
    cat >/dev/tty << _BREAK_
Installation utility for RetroPie-Extra, a supplement to RetroPie

Usage:

    ./$(basename "$0") [option] [rp_setup_directory]

Options (up to one):
    -g, --gui       Run the installer in GUI mode. Choose which modules to include.
                    This is the default mode if no other option is selected.

    -a, --all,      Copy all RetroPie-Extra modules and exit (may severely impact the
        --auto      loading time of RetroPie-Setup and retropiemenu configuration
                    items, especially on slower hardware)

    -r, --remove    Remove all RetroPie-Extra modules and exit (does not "uninstall"
                    the modules in RP-Setup)

    -u, --update    Update RetroPie-Extra to the latest version and exit

    -h, --help      Display this help and exit
_BREAK_
exit
}

SCRIPTDIR="$(dirname "$0")"
SCRIPTDIR="$(cd "$SCRIPTDIR" && pwd)"
readonly SCRIPTDIR

MODE="gui"
case "${1,,}" in
    -g|--gui)
        shift
        ;;
    -a|--all|--auto)
        MODE="auto"
        shift
        ;;
    -r|--remove)
        MODE="remove"
        shift
        ;;
    -u|--update)
        git pull origin
        exit
        ;;
    -*)
        runHelp
        exit
        ;;
esac
readonly MODE

RPS_HOME="$HOME/RetroPie-Setup"
if [[ -n "$1" ]]; then
    RPS_HOME="$1"
fi
readonly RPS_HOME

readonly RP_EXTRA="$RPS_HOME/ext/RetroPie-Extra"
readonly BACKTITLE="Installation utility for RetroPie-Extra - Setup directory: $RPS_HOME"
readonly REGEX='^[0-9]+$'

function startCmd() {
    if [[ ! -d "$RPS_HOME" ]]; then
        echo -e "Error: RetroPie-Setup directory $RPS_HOME does not exist. Please input the location of RetroPie-Setup, ex:\n\n    ./$(basename "$0") /home/pi/RetroPie-Setup\n\nUse '-h' for help. Aborting."
        exit
    fi

    pushd $RPS_HOME
    if ! git log --format=format:%H | grep 18c2b43000ec54d74ba016e0b8de654122377dba; then
        echo -e "Error: Your RetroPie-Setup directory is too old.  Please update your RetroPie-Setup by running 'git pull origin master' inside your RetroPie-Setup directory."
        popd
        exit
    fi
    popd

    case "$MODE" in
        auto) runAuto ;;
        remove) removeAll ;;
        *) runGui ;;
    esac
}

function runAuto() {
    echo -e "Placing scriptmodules in $RP_EXTRA\n"
    mkdir -p "$RP_EXTRA"
    cp -rp "$SCRIPTDIR/scriptmodules/" "$RP_EXTRA" && echo "...done."
    exit
}

function removeAll() {
    if [[ ! -d "$RP_EXTRA" ]]; then
        echo -e "RetroPie-Extra directory $RP_EXTRA does not exist. Nothing to remove.\n\nAborting."
        exit
    fi

    echo -e "Removing directory $RP_EXTRA and all of its contents.\n"
    rm -rf "$RP_EXTRA" && echo "...done."
    exit
}

function runGui() {
    while true; do
        local cmd=(dialog --clear --backtitle "$BACKTITLE" --cancel-label "Exit" --menu "Choose an option" 22 86 16)
        local options=(
            1 "Choose which modules to install"
            2 "View or remove installed modules"
            3 "Install by section"
            4 "Update RetroPie-Extra"
            5 "Install all RetroPie-Extra modules"
            6 "Remove all RetroPie-Extra modules"
        )
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1) chooseModules ;;
                2) viewModules ;;
                3) installBySection ;;
                4) updateExtras ;;
                5) guiAddAll ;;
                6) guiRemoveAll ;;
            esac
        else
            break
        fi
    done

    clear
}

function guiAddAll() {
    if dialog --clear --backtitle "$BACKTITLE" --cr-wrap --no-collapse --defaultno --yesno "-- Install all\n\nThis may severely impact the loading times of RetroPie-Setup and retropiemenu configuration items, especially on slower hardware.\n\nDo you wish to continue?" 20 60 2>&1 >/dev/tty; then
        local errormsg="$(mkdir -p "$RP_EXTRA" 2>&1 && cp -rpf "$SCRIPTDIR/scriptmodules" "$RP_EXTRA" 2>&1 && echo "All scriptmodules copied to $RP_EXTRA")"
        dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --programbox 20 60 2>&1 >/dev/tty < <(echo "$errormsg" | fold -w 56 -s)
    else
        dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --msgbox "Operation canceled." 8 24 2>&1 >/dev/tty
    fi
}

function guiRemoveAll() {
    if [[ ! -d "$RP_EXTRA" ]]; then
        dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --msgbox "-- Remove All\n\nRetroPie-Extra directory $RP_EXTRA does not exist. Nothing to remove.\n\nAborting." 20 60 2>&1 >/dev/tty
    elif dialog --clear --backtitle "$BACKTITLE" --cr-wrap --no-collapse --defaultno --yesno "-- Remove All\n\nRemoving directory $RP_EXTRA and all of its contents.\n\nDo you wish to continue?" 20 60 2>&1 >/dev/tty; then
        local errormsg="$(rm -rf "$RP_EXTRA" 2>&1 && echo "...done.")"
        dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --programbox "Removing all RetroPie-Extra scriptmodules..." 20 60 2>&1 >/dev/tty < <(echo "$errormsg" | fold -w 56 -s)
    else
        dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --msgbox "Operation canceled." 8 24 2>&1 >/dev/tty
    fi
}

function chooseModules() {
    local menu=()
    local options=()
    local module
    local name
    local section
    local lastsection
    local installed

    local i=1
    while read module; do
        section="$(basename "$(dirname "$module")")"
        name="$(basename "$module")"
        module="$section/$name"

        if [[ "$section" != "$lastsection" ]]; then
            menu+=("---" "--- $section ---" off)
        fi

        installed="off"
        [[ -f "$RP_EXTRA/scriptmodules/$module" ]] && installed="on"
        menu+=($i "$name" "$installed")
        options+=("$module")
        ((i++))
        lastsection="$section"
    done < <(find "$SCRIPTDIR/scriptmodules" -mindepth 2 -maxdepth 2 -type f | sort -u)

    if [[ "${#options[@]}" -gt 0 ]]; then
        local cmd=(dialog --clear --backtitle "$BACKTITLE" --cancel-label "Back" --checklist "Choose which modules to install:" 22 76 16)
        local choices
        choices=($("${cmd[@]}" "${menu[@]}" 2>&1 >/dev/tty)) || return

        local choice
        local errormsg="$(
            for choice in "${choices[@]}"; do
                if [[ "$choice" =~ $REGEX ]]; then
                    choice="${options[choice-1]}"
                    copyModule "$choice"
                fi
            done
        )"

        local n="${#choices[@]}"
        if [[ -n "$errormsg" ]]; then
            errormsg="Error: $errormsg"
        elif [[ $n -eq 0 ]]; then
            errormsg="Error: no scriptmodules selected"
        else
            errormsg="$n selected scriptmodules have been copied to $RP_EXTRA"
        fi
        dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --programbox 20 60 2>&1 >/dev/tty < <(echo "$errormsg" | fold -w 56 -s)
    elif dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --defaultno --yesno "Error: no scriptmodules found in repository. You may attempt repair with 'git checkout -- $SCRIPTDIR/scriptmodules'. If error persists, please open a new issue at https://github.com/Exarkuniv/RetroPie-Extra/issues/new\n\nWould you like to attempt repair now?" 20 60 2>&1 >/dev/tty; then
        local errormsg="$(git checkout -- "$SCRIPTDIR/scriptmodules" 2>&1)"
        if [[ -n "$errormsg" ]]; then
            errormsg="Error: $errormsg"
        else
            errormsg="The RetroPie-Extra scriptmodules directory has been restored."
        fi
        dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --programbox 20 60 2>&1 >/dev/tty < <(echo "$errormsg" | fold -w 56 -s)
    fi
}

function copyModule() {
    local choice="$1"
    local section="$(dirname "$choice")"
    local script="$SCRIPTDIR/scriptmodules/$choice"
    local target="$RP_EXTRA/scriptmodules/$section"
    local datadir="${script%.*}"

    mkdir -p "$target" 2>&1 \
      && cp -pf "$script" "$target" 2>&1 \
      && [[ ! -d "$datadir" ]] || cp -rpf "$datadir" "$target" 2>&1
}

function viewModules() {
    local menu=()
    local options=()
    local module
    local name
    local section
    local lastsection

    local i=1
    while read module; do
        section="$(basename "$(dirname "$module")")"
        name="$(basename "$module")"
        module="$section/$name"
        if [[ "$section" != "$lastsection" ]]; then
            menu+=("---" "--- $section ---" off)
        fi
        menu+=($i "$name" on)
        options+=("$module")
        ((i++))
        lastsection="$section"
    done < <(find "$RP_EXTRA/scriptmodules" -mindepth 2 -maxdepth 2 -type f | sort -u)

    if [[ -n "${options[@]}" ]]; then
        local cmd=(dialog --clear --backtitle "$BACKTITLE" --cancel-label "Back" --checklist "The following modules are installed:" 22 76 16)
        local choices
        choices=($("${cmd[@]}" "${menu[@]}" 2>&1 >/dev/tty)) || return
        local choice

        local keeps=()
        for choice in "${choices[@]}"; do
            if [[ "$choice" =~ $REGEX ]]; then
                choice="${options[choice-1]}"
                keeps+=("$choice")
            fi
        done

        local removes=()
        for choice in "${options[@]}"; do
            [[ " ${keeps[*]} " =~ " $choice " ]] || removes+=("$choice")
        done

        [[ "${#removes[@]}" -eq 0 ]] && return

        if dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --defaultno --yesno "The following modules will be removed. Do you wish to continue?\n\n$(printf '    %s\n' "${removes[@]}")" 20 60 2>&1 >/dev/tty; then
            local errormsg="$(
                for choice in "${removes[@]}"; do
                    deleteModule "$choice"
                done
            )"

            if [[ -n "$errormsg" ]]; then
                errormsg="Error: $errormsg"
            else
                errormsg="${#removes[@]} selected scriptmodules removed."
            fi

            dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --programbox 20 60 2>&1 >/dev/tty < <(echo "$errormsg" | fold -w 56 -s)
        else
            dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --msgbox "Operation canceled." 8 24 2>&1 >/dev/tty
        fi
    else
        dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --msgbox "Error: no scriptmodules installed" 20 60 2>&1 >/dev/tty
    fi
}

function deleteModule() {
    local choice="$1"
    local script="$RP_EXTRA/scriptmodules/$choice"
    local section="$(dirname "$script")"
    local datadir="${script%.*}"
    rm -f "$script" 2>&1 \
      && [[ ! -d "$datadir" ]] || rm -rf "$datadir" 2>&1 \
      && [[ ! -d "$section" ]] || [[ -n "$(ls -A "$section" 2>&1)" ]] || rmdir "$section" 2>&1 \
      && [[ ! -d "$RP_EXTRA/scriptmodules" ]] || [[ -n "$(ls -A "$RP_EXTRA/scriptmodules" 2>&1)" ]] || rmdir "$RP_EXTRA/scriptmodules" 2>&1 \
      && [[ ! -d "$RP_EXTRA" ]] || [[ -n "$(ls -A "$RP_EXTRA" 2>&1)" ]] || rmdir "$RP_EXTRA" 2>&1
}

function installBySection() {
    while true; do
        local cmd=(dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --cancel-label "Back" --menu "Install by section:" 22 76 16)
        local options=(
            1 "Emulators"
            2 "Libretrocores"
            3 "Ports"
            4 "Supplementary"
        )

        local section
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1) section="emulators" ;;
                2) section="libretrocores" ;;
                3) section="ports" ;;
                4) section="supplementary" ;;
            esac

            guiSection "$section"
        else
            break
        fi
    done
}

function guiSection() {
    while true; do
        local section="$1"
        local cmd=(dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --cancel-label "Back" --menu "${section^}:" 20 60 16)
        local options=(
            1 "Choose which $section to install"
            2 "View or remove installed $section"
            3 "Install all $section"
            4 "Remove all $section"
        )
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1) chooseBySection "$section" ;;
                2) viewBySection "$section" ;;
                3) addSection "$section" ;;
                4) removeSection "$section" ;;
            esac
        else
            break
        fi
    done
}

function addSection() {
    local section="$1"
    if dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --defaultno --yesno "All $section will be copied to $RP_EXTRA\n\nThis may significantly impact the loading time of RetroPie-Setup and retropiemenu configuration items, especially on slower hardware.\n\nDo you wish to continue?" 20 60 2>&1 >/dev/tty; then
        local errormsg="$(mkdir -p "$RP_EXTRA/scriptmodules/$section" 2>&1 && cp -rpf "$SCRIPTDIR/scriptmodules/$section" "$RP_EXTRA/scriptmodules" 2>&1 && echo "All $section copied to $RP_EXTRA")"
        dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --programbox 20 60 2>&1 >/dev/tty < <(echo "$errormsg" | fold -w 56 -s)
    else
        dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --msgbox "Operation canceled." 8 24 2>&1 >/dev/tty
    fi
}

function removeSection() {
    local section="$1"
    if [[ ! -d "$RP_EXTRA/scriptmodules/$section" ]]; then
        dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --msgbox "${section^} directory $RP_EXTRA/scriptmodules/$section does not exist. Nothing to remove.\n\nAborting." 20 60 2>&1 >/dev/tty
    elif dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --defaultno --yesno "Removing directory $RP_EXTRA/scriptmodules/$section and all of its contents.\n\nDo you wish to continue?" 20 60 2>&1 >/dev/tty; then
        local errormsg="$(
            rm -rf "$RP_EXTRA/scriptmodules/$section" \
              && [[ ! -d "$RP_EXTRA/scriptmodules" ]] || [[ -n "$(ls -A "$RP_EXTRA/scriptmodules" 2>&1)" ]] || rmdir "$RP_EXTRA/scriptmodules" 2>&1 \
              && [[ ! -d "$RP_EXTRA" ]] || [[ -n "$(ls -A "$RP_EXTRA" 2>&1)" ]] || rmdir "$RP_EXTRA" 2>&1 \
              && echo "...done"
        )"
        dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --programbox "Removing $section..." 20 60 2>&1 >/dev/tty < <(echo "$errormsg" | fold -w 56 -s)
    else
        dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --msgbox "Operation canceled." 8 24 2>&1 >/dev/tty
    fi
}

function chooseBySection() {
    local section="$1"

    local menu=()
    local options=()
    local module
    local installed

    local i=1
    while read module; do
        module="$(basename "$module")"
        installed="off"
        [[ -f "$RP_EXTRA/scriptmodules/$section/$module" ]] && installed="on"
        menu+=($i "$module" "$installed")
        options+=("$module")
        ((i++))
    done < <(find "$SCRIPTDIR/scriptmodules/$section" -mindepth 1 -maxdepth 1 -type f | sort -u)

    if [[ "${#options[@]}" -gt 0 ]]; then
        local cmd=(dialog --clear --backtitle "$BACKTITLE" --cancel-label "Back" --checklist "Choose which $section to install:" 22 76 16)
        local choices
        choices=($("${cmd[@]}" "${menu[@]}" 2>&1 >/dev/tty)) || return

        local choice
        local errormsg="$(
            for choice in "${choices[@]}"; do
                if [[ "$choice" =~ $REGEX ]]; then
                    choice="${options[choice-1]}"
                    copyModule "$section/$choice"
                fi
            done
        )"

        local n="${#choices[@]}"
        if [[ -n "$errormsg" ]]; then
            errormsg="Error: $errormsg"
        elif [[ $n -eq 0 ]]; then
            errormsg="Error: no scriptmodules selected"
        else
            errormsg="$n selected $section have been copied to $RP_EXTRA"
        fi
        dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --programbox 20 60 2>&1 >/dev/tty < <(echo "$errormsg" | fold -w 56 -s)
    elif dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --defaultno --yesno "Error: no scriptmodules found in repository. You may attempt repair with 'git checkout -- $SCRIPTDIR/scriptmodules'. If error persists, please open a new issue at https://github.com/Exarkuniv/RetroPie-Extra/issues/new\n\nWould you like to attempt repair now?" 20 60 2>&1 >/dev/tty; then
        local errormsg="$(git checkout -- "$SCRIPTDIR/scriptmodules" 2>&1)"
        if [[ -n "$errormsg" ]]; then
            errormsg="Error: $errormsg"
        else
            errormsg="The RetroPie-Extra scriptmodules directory has been restored."
        fi
        dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --programbox 20 60 2>&1 >/dev/tty < <(echo "$errormsg" | fold -w 56 -s)
    fi
}

function viewBySection() {
    local section="$1"

    local menu=()
    local options=()
    local module

    local i=1
    while read module; do
        module="$(basename "$module")"
        menu+=($i "$module" on)
        options+=("$module")
        ((i++))
    done < <(find "$RP_EXTRA/scriptmodules/$section" -mindepth 1 -maxdepth 1 -type f | sort -u)

    if [[ -n "${options[@]}" ]]; then
        local cmd=(dialog --clear --backtitle "$BACKTITLE" --cancel-label "Back" --checklist "The following $section are installed:" 22 76 16)
        local choices
        choices=($("${cmd[@]}" "${menu[@]}" 2>&1 >/dev/tty)) || return
        local choice

        local keeps=()
        for choice in "${choices[@]}"; do
            if [[ "$choice" =~ $REGEX ]]; then
                choice="${options[choice-1]}"
                keeps+=("$choice")
            fi
        done

        local removes=()
        for choice in "${options[@]}"; do
            [[ " ${keeps[*]} " =~ " $choice " ]] || removes+=("$choice")
        done

        [[ "${#removes[@]}" -eq 0 ]] && return

        if dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --defaultno --yesno "The following $section will be removed. Do you wish to continue?\n\n$(printf '    %s\n' "${removes[@]}")" 20 60 2>&1 >/dev/tty; then
            local errormsg="$(
                for choice in "${removes[@]}"; do
                    deleteModule "$section/$choice"
                done
            )"

            if [[ -n "$errormsg" ]]; then
                errormsg="Error: $errormsg"
            else
                errormsg="${#removes[@]} selected $section removed."
            fi

            dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --programbox 20 60 2>&1 >/dev/tty < <(echo "$errormsg" | fold -w 56 -s)
        else
            dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --msgbox "Operation canceled." 8 24 2>&1 >/dev/tty
        fi
    else
        dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --msgbox "Error: no $section installed" 20 60 2>&1 >/dev/tty
    fi
}

function updateExtras () {
    if dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --defaultno --yesno "Running 'git pull origin'\n\nWould you like to continue?" 20 60 2>&1 >/dev/tty; then
        local errormsg="$(git pull origin 2>&1)"
        dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --programbox "Updating RetroPie-Extra" 20 60 2>&1 >/dev/tty < <(echo "$errormsg" | fold -w 56 -s)
    else
        dialog --backtitle "$BACKTITLE" --cr-wrap --no-collapse --msgbox "Operation canceled." 8 24 2>&1 >/dev/tty
    fi
}

# Run
startCmd
