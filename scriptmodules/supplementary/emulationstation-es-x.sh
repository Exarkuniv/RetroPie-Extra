#!/usr/bin/env bash

# This file is part of RetroPie-Extra, a supplement to RetroPie.
# For more information, please visit:
#
# this was made by RapidEdwin08 i dont take any credit for this in anyway
#
# https://github.com/RetroPie/RetroPie-Setup
# https://github.com/Exarkuniv/RetroPie-Extra
# https://github.com/Renetrox/EmulationStation-X
# https://github.com/RapidEdwin08/RetroPie-Setup
#
# See the LICENSE file distributed with this source and at
# https://raw.githubusercontent.com/Exarkuniv/RetroPie-Setup/master/ext/RetroPie-Extra/LICENSE
#
# ============================================================
#  EmulationStation-X (ES-X) for RetroPie
#  Experimental fork with .ini language support + theme system
#  by Renetrox
#
#  This module REPLACES the standard EmulationStation.
#  Installs ES-X + its language files + default ES-X themes.
# ============================================================
#
# If no user is specified (for RetroPie below v4.8.9)
if [[ -z "$__user" ]]; then __user="$SUDO_USER"; [[ -z "$__user" ]] && __user="$(id -un)"; fi

rp_module_id="emulationstation-es-x"
rp_module_desc="EmulationStation-X (ES-X) - Experimental fork with .ini language and theme enhancements (replaces standard EmulationStation)"
rp_module_help="After installing, ES-X becomes the main frontend. Includes automatic language .ini installation and default ES-X themes.\n\nBGM Folder(s):\n$home/RetroPie/music\n$home/.emulationstation/music"
rp_module_section="exp"
rp_module_flags="frontend"

rp_module_licence="MIT https://github.com/Aloshi/EmulationStation/blob/master/LICENSE"

# ES-X repository
rp_module_repo="git https://github.com/Renetrox/EmulationStation-X main"

# ------------------------------------------------------------
# Link to base EmulationStation build system
# ------------------------------------------------------------
function _update_hook_emulationstation-es-x() { _update_hook_emulationstation; }
function depends_emulationstation-es-x()      { depends_emulationstation; }
#function sources_emulationstation-es-x()      { sources_emulationstation; }
function sources_emulationstation-es-x() {
    sources_emulationstation

    # [Trixie] error: conflicting declaration ‘typedef int Mix_Music’ # BackgroundMusicManager.h:9:27: note: previous declaration as ‘typedef struct _Mix_Music Mix_Music’
    if [[ "$__gcc_version" -gt 12 ]]; then
        sed -i "s+^struct _Mix_Music\;+struct Mix_Music\;+" "$md_build/es-app/src/audio/BackgroundMusicManager.h"
        sed -i "s+typedef struct _Mix_Music Mix_Music+//typedef struct _Mix_Music Mix_Music+" "$md_build/es-app/src/audio/BackgroundMusicManager.h"
    fi

    # [x3] 0ptional JoyPad Connected Popup Changes
    ##sed -i "s+window->setInfoPopup(new GuiInfoPopup(window, std::string(\"★ Connected+window->setInfoPopup(new GuiInfoPopup(window, std::string(\"Connected+" "$md_build/es-core/src/InputManager.cpp" # Remove Star Only
    ##sed -i "s+window->setInfoPopup(new GuiInfoPopup(window, std::string(\"★ Connected: \") \+ joyName,+window->setInfoPopup(new GuiInfoPopup(window, joyName \+ std::string(\" Connected\"),+" "$md_build/es-core/src/InputManager.cpp" # Reverse string<->joyName
    sed -i "s+window->setInfoPopup(new GuiInfoPopup(window, std::string(\"★ Connected+//window->setInfoPopup(new GuiInfoPopup(window, std::string(\"Connected+" "$md_build/es-core/src/InputManager.cpp" # Remove Connected Message

    # [x3] 0ptional JoyPad Disconnected Popup Changes
    ##sed -i "s+window->setInfoPopup(new GuiInfoPopup(window, std::string(\"★ Disconnected+window->setInfoPopup(new GuiInfoPopup(window, std::string(\"Disconnected+" "$md_build/es-core/src/InputManager.cpp" # Remove Star Only
    sed -i "s+window->setInfoPopup(new GuiInfoPopup(window, std::string(\"★ Disconnected: \") \+ joyName,+window->setInfoPopup(new GuiInfoPopup(window, joyName \+ std::string(\" Disconnected\"),+" "$md_build/es-core/src/InputManager.cpp" # Reverse string<->joyName
    ##sed -i "s+window->setInfoPopup(new GuiInfoPopup(window, std::string(\"★ Disconnected+//window->setInfoPopup(new GuiInfoPopup(window, std::string(\"Disconnected+" "$md_build/es-core/src/InputManager.cpp" # Remove Disconnected Message
}
function build_emulationstation-es-x()        { build_emulationstation; }
function install_emulationstation-es-x()      { install_emulationstation; }

# ------------------------------------------------------------

function configure_emulationstation-es-x() {

    # ============================================================
    # 1) Remove standard EmulationStation
    # ============================================================
    echo "Removing original EmulationStation..."
    rp_callModule "emulationstation" remove

    # ============================================================
    # 2) Configure ES-X using upstream logic
    # ============================================================
    echo "Configuring ES-X..."
    configure_emulationstation

    # ============================================================
    # 3) Install language files (.ini)
    # ============================================================
    echo "Installing ES-X language files..."

    local lang_src=""
    local lang_dst="$home/.emulationstation/lang"

    if [[ -d "$md_build/lang" ]]; then
        lang_src="$md_build/lang"
    elif [[ -d "$md_inst/lang" ]]; then
        lang_src="$md_inst/lang"
    elif [[ -d "$md_inst/resources/lang" ]]; then
        lang_src="$md_inst/resources/lang"
    fi

    if [[ -n "$lang_src" ]]; then
        mkUserDir "$lang_dst"
        cp -v "$lang_src"/* "$lang_dst"/ 2>/dev/null
        chown -R "$__user:$__user" "$lang_dst"
        echo "Language files installed at $lang_dst"
    else
        echo "WARNING: No 'lang' folder found for ES-X."
    fi

    # ============================================================
    # 3.5) Ensure RetroPie music folder exists (NO default music)
    # ============================================================
    if [[ -d /opt/retropie/configs/imp ]] || [[ -d /home/$__user/imp ]]; then
        echo "IMP FOUND: SKIP Creating ES-X [music] Folders: [$home/RetroPie/music] [$home/.emulationstation/music]"
    else
        echo "Creating ES-X [music] Folders: [$home/RetroPie/music] [$home/.emulationstation/music]"
        mkUserDir "$home/RetroPie/music"
        mkUserDir "$home/.emulationstation/music"
    fi

    # ============================================================
    # 4) Install / update ES-X themes
    # ============================================================
    echo "Installing ES-X themes..."
    local themes_dir="$home/.emulationstation/themes"
    mkUserDir "$themes_dir"

    install_esx_theme() {
        local repo="$1"
        local folder="$2"
        local target="$themes_dir/$folder"

        if [[ -d "$target/.git" ]]; then
            echo "Checking updates for theme: $folder"
            git -C "$target" fetch --quiet

            if [[ -n "$(git -C "$target" status -uno | grep 'behind')" ]]; then
                echo "Updating theme: $folder"
                git -C "$target" pull --ff-only
            else
                echo "Theme already up to date: $folder"
            fi

        elif [[ -d "$target" ]]; then
            echo "Theme folder exists but is not a git repository: $folder — leaving untouched."

        else
            echo "Cloning theme: $folder"
            git clone "$repo" "$target"
            chown -R "$__user:$__user" "$target"
        fi
    }

    #install_esx_theme "https://github.com/Renetrox/art-book-next-ESX" "art-book-next-ESX"
    #install_esx_theme "https://github.com/Renetrox/Alekfull-nx-retropie" "Alekfull-nx-retropie"
    #install_esx_theme "https://github.com/Renetrox/Mini" "Mini"
    install_esx_theme "https://github.com/RapidEdwin08/metapixel-doomed" "metapixel-doomed"

    # Extra Systems for carbon-2021: cdimono1 cd-i cloud doom godot-engine j2me jaguarcd openbor wine
    if [[ ! -f "/etc/emulationstation/themes/carbon-2021/art/systems/doom.svg" ]] && [[ -d "/etc/emulationstation/themes/carbon-2021" ]]; then
        downloadAndExtract "https://raw.githubusercontent.com/RapidEdwin08/RetroPie-Setup-Assets/main/supplementary/emulationstation-es-x-rp-assets.tar.gz" "/etc/emulationstation/themes"
    fi

    echo "Themes installed."

    # ============================================================
    # 5) Apply default theme ONLY on first install
    # ============================================================
    local es_settings="$home/.emulationstation/es_settings.cfg"

    if [[ ! -f "$es_settings" ]] || ! grep -q "<string name=\"ThemeSet\"" "$es_settings"; then
        echo "Applying default ES-X theme: metapixel-doomed"

        mkUserDir "$(dirname "$es_settings")"
        touch "$es_settings"

        if grep -q "<string name=\"ThemeSet\"" "$es_settings"; then
            sed -i 's|<string name="ThemeSet".*|<string name="ThemeSet" value="metapixel-doomed" />|' "$es_settings"
        else
            echo '<string name="ThemeSet" value="metapixel-doomed" />' >> "$es_settings"
        fi

        chown "$__user:$__user" "$es_settings"
    else
        echo "Theme already configured by user — not changing."
    fi

    # Disable Built-In BGM in es_settings.cfg IF IMP found
    if [[ -d /opt/retropie/configs/imp ]] || [[ -d /home/$__user/imp ]]; then
        echo IMP FOUND: Setting [BackgroundMusic=false] in [es_settings.cfg]
        sed -i "s+BackgroundMusic\" value=.*+BackgroundMusic\" value=\"false\" /\>+" "$home/.emulationstation/es_settings.cfg"
    fi

    echo "ES-X configuration complete."
}

function remove_emulationstation-es-x() { remove_emulationstation; }
function gui_emulationstation-es-x()    { gui_emulationstation; }
