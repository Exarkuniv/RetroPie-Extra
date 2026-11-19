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

#!/usr/bin/env bash

rp_module_id="lr-colortvgame"
rp_module_desc="Color TV-Game Simulator - Nintendo Color TV-Game 6/15 + Racing 112 (libretro)"
rp_module_help="ROM Extension: .ctg\n\nNo ROMs needed: the games are built into the core. The 16 .ctg selectors from the project are copied to $romdir/colortvgame, plus \"Game Selector.ctg\", which opens the core's built-in game menu."
rp_module_licence="MIT https://raw.githubusercontent.com/d-cglt/color-tv-game-simulator/master/LICENSE"
rp_module_repo="git https://github.com/d-cglt/color-tv-game-simulator.git :_get_branch_lr-colortvgame"
rp_module_section="exp"
rp_module_flags=""

################################
# SYSTEM SETTINGS
#
# Short system name (ROM folder, config folder, ES theme) and its position in
# /etc/emulationstation/es_systems.cfg: the entry is placed just before the
# system named in _ctg_es_before (Nintendo chronology: Color TV-Game 1977,
# Game & Watch 1980). If that system is not present, the entry goes at the end.
################################
_ctg_sys="colortvgame"
_ctg_fullname="Nintendo Color TV-Game"
_ctg_es_before="gameandwatch"
_ctg_selector="Game Selector"

################################
# VERSION TO BUILD
#
# Latest vX.Y.Z tag published on GitHub (v0.1.7 on 2026-11-18), not master:
# master may hold the author's work in progress. To force a version:
#     CTG_REF=master sudo -E ./retropie_setup.sh
################################
function _get_branch_lr-colortvgame() {
    if [[ -n "$CTG_REF" ]]; then
        echo "$CTG_REF"
        return
    fi
    local tag
    tag="$(git ls-remote --tags --refs https://github.com/d-cglt/color-tv-game-simulator.git 'v*' 2>/dev/null \
        | sed 's|.*refs/tags/||' | sort -V | tail -1)"
    echo "${tag:-master}"
}

function depends_lr-colortvgame() {
    getDepends cmake xmlstarlet
}

function sources_lr-colortvgame() {
    gitPullOrClone
}

function build_lr-colortvgame() {
    ################################
    # CMake picks up the CXXFLAGS that RetroPie-Setup exports for the platform
    # (-mcpu=cortex-a76 on Pi 5, cortex-a72 on Pi 4, etc.): no CPU flags here.
    # GCC 8 (Buster): std::filesystem still needs libstdc++fs.
    # Only the core target is built (no test suite: faster on a Pi).
    ################################
    local extra=""
    compareVersions "$__gcc_version" lt 9 && extra="-lstdc++fs"

    rm -rf build
    cmake -S . -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_STANDARD_LIBRARIES="$extra" \
        -DBUILD_TESTING=OFF
    cmake --build build --target colortvgame_libretro -j"$(nproc)"
    md_ret_require="$md_build/build/colortvgame_libretro.so"
}

function install_lr-colortvgame() {
    md_ret_files=(
        'build/colortvgame_libretro.so'
        'colortvgame_libretro.info'
        'content'
        'LICENSE'
        'README.md'
    )
}

################################
# ENTRY IN /etc/emulationstation/es_systems.cfg
#
# addSystem is NOT used for the install: after adding an entry it sorts the
# whole file by system name (_sort_systems_emulationstation), which would undo
# any custom order (arcade and fba first, etc.). The entry is written here
# instead, with xmlstarlet like RetroPie-Setup, just before $_ctg_es_before
# (or at the end of the list if that system is absent). Nothing else in the
# file moves. Running the install again rewrites the entry at the same place.
# Note: any OTHER module installed later with RetroPie-Setup still sorts the
# file by name through its own addSystem call.
################################
function _es_place_lr-colortvgame() {
    local conf="/etc/emulationstation/es_systems.cfg"
    local sys="$_ctg_sys"
    local target="${CTG_ES_BEFORE:-$_ctg_es_before}"

    if [[ ! -f "$conf" ]]; then
        # no file yet: let RetroPie-Setup create it the standard way
        addSystem "$sys" "$_ctg_fullname" ".ctg"
        return
    fi

    local backup="$conf.before-$sys"
    cp "$conf" "$backup"
    xmlstarlet ed -L -d "/systemList/system[name='$sys']" "$conf"

    local where="at the end of the list"
    if [[ "$(xmlstarlet sel -t -v "count(/systemList/system[name='$target'])" "$conf")" -gt 0 ]]; then
        xmlstarlet ed -L -i "/systemList/system[name='$target']" -t elem -n "system" -v "" "$conf"
        where="before <$target>"
    else
        xmlstarlet ed -L -s "/systemList" -t elem -n "system" -v "" "$conf"
    fi
    xmlstarlet ed -L \
        -s "/systemList/system[not(name)]" -t elem -n "name" -v "$sys" \
        -s "/systemList/system[name='$sys']" -t elem -n "fullname" -v "$_ctg_fullname" \
        -s "/systemList/system[name='$sys']" -t elem -n "path" -v "$romdir/$sys" \
        -s "/systemList/system[name='$sys']" -t elem -n "extension" -v ".ctg .CTG" \
        -s "/systemList/system[name='$sys']" -t elem -n "command" \
            -v "$rootdir/supplementary/runcommand/runcommand.sh 0 _SYS_ $sys %ROM%" \
        -s "/systemList/system[name='$sys']" -t elem -n "platform" -v "$sys" \
        -s "/systemList/system[name='$sys']" -t elem -n "theme" -v "$sys" \
        "$conf"

    # guard: valid XML, exactly one entry, same number of other systems as before
    local before after
    before="$(xmlstarlet sel -t -v "count(/systemList/system[name!='$sys'])" "$backup")"
    after="$(xmlstarlet sel -t -v "count(/systemList/system[name!='$sys'])" "$conf")"
    if ! xmlstarlet val -q "$conf" \
       || [[ "$(xmlstarlet sel -t -v "count(/systemList/system[name='$sys'])" "$conf")" -ne 1 ]] \
       || [[ "$before" -ne "$after" ]]; then
        cp "$backup" "$conf"
        echo "!! es_systems.cfg: edit failed, file restored from $backup"
        return 1
    fi
    rm -f "$backup"
    echo "es_systems.cfg: <$sys> written $where (other systems untouched)"

    # EmulationStation reads only the user copy when it exists
    local conf_local="$configdir/all/emulationstation/es_systems.cfg"
    if [[ -f "$conf_local" ]]; then
        echo "!! $conf_local exists: EmulationStation reads only that file and"
        echo "!! ignores $conf. Delete it, or copy the <$sys> entry into it."
    fi
}

function configure_lr-colortvgame() {
    local sys="$_ctg_sys"
    local racfg="$md_conf_root/$sys/retroarch.cfg"

    ################################
    # PER-ROM KEY FOR runcommand
    #
    # runcommand looks up, in $configdir/all/emulators.cfg, the key
    # clean_name("<system>_<file name without extension>"); clean_name drops
    # anything that is not a letter, digit, _ or -, so "Game Selector" becomes
    # colortvgame_GameSelector. That key forces the launch line without %ROM%
    # for this file only.
    ################################
    local key="${sys}_${_ctg_selector}"
    key="${key//\//_}"
    key="${key//[^a-zA-Z0-9_\-]/}"

    if [[ "$md_mode" == "remove" ]]; then
        [[ -f "$configdir/all/emulators.cfg" ]] && sed -i "/^$key[[:space:]]*=/d" "$configdir/all/emulators.cfg"
        addEmulator 1 "$md_id" "$sys" "$md_inst/colortvgame_libretro.so"
        addEmulator 0 "$md_id-selector" "$sys" ""
        addSystem "$sys" "$_ctg_fullname" ".ctg"
        return
    fi

    mkRomDir "$sys"

    ################################
    # Per-system retroarch.cfg with a fixed save folder. Without it, a launch
    # without content (Game Selector) has no save folder and the core can keep
    # neither its game settings nor the last selected game.
    # If the file already exists and differs, RetroPie writes retroarch.cfg.rp-dist.
    ################################
    defaultRAConfig "$sys" "savefile_directory" "$romdir/$sys"

    # normal line: RetroPie builds the RetroArch command with %ROM%
    addEmulator 1 "$md_id" "$sys" "$md_inst/colortvgame_libretro.so"
    # built-in menu line: same command WITHOUT %ROM% -> the core starts on its selector
    addEmulator 0 "$md_id-selector" "$sys" \
        "$emudir/retroarch/bin/retroarch -L $md_inst/colortvgame_libretro.so --config $racfg"
    _es_place_lr-colortvgame

    ################################
    # .ctg SELECTORS: 5 bytes each, not ROMs. An existing file is never
    # overwritten. "Game Selector.ctg" is a copy of a valid selector: if the
    # per-ROM key above is ever lost, it starts Tennis instead of failing.
    ################################
    local f
    for f in "$md_inst"/content/*.ctg; do
        [[ -e "$romdir/$sys/${f##*/}" ]] || cp "$f" "$romdir/$sys/"
    done
    [[ -e "$romdir/$sys/$_ctg_selector.ctg" ]] || \
        cp "$md_inst/content/Tennis Original - Singles (Color TV Game 6 + 15).ctg" \
           "$romdir/$sys/$_ctg_selector.ctg"
    chown -R "$__user":"$__group" "$romdir/$sys"

    iniConfig " = " '"' "$configdir/all/emulators.cfg"
    iniSet "$key" "$md_id-selector"
    chown "$__user":"$__group" "$configdir/all/emulators.cfg"

    echo ""
    echo "Launch lines installed ($md_conf_root/$sys/emulators.cfg):"
    cat "$md_conf_root/$sys/emulators.cfg"
    echo "Per-ROM key: $key = \"$md_id-selector\""
    echo ""
}
