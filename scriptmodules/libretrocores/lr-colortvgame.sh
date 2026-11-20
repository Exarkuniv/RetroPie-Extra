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

rp_module_id="lr-colortvgame"
rp_module_desc="Color TV-Game Simulator - Nintendo Color TV-Game 6/15 + Racing 112 (libretro)"
rp_module_help="ROM Extension: .ctg

No ROMs needed: the games are built into the core. The 16 .ctg selectors are copied to $romdir/colortvgame with standardized names (tennis_original_singles.ctg, ...), plus game_selector.ctg, which opens the core's built-in game menu. The gamelist.xml and media (images, logos, videos) come from https://github.com/DTEAM-1/test/tree/main/colortvgame.

Supported: Raspberry Pi Zero / 1, Zero 2 / 3, 4 and 5 (32-bit or 64-bit), and x86 / x86_64 PCs. The core is built from source on the machine."
rp_module_licence="MIT https://raw.githubusercontent.com/d-cglt/color-tv-game-simulator/master/LICENSE"
rp_module_repo="git https://github.com/d-cglt/color-tv-game-simulator.git :_get_branch_lr-colortvgame"
rp_module_section="exp"
rp_module_flags=""

################################
# SUPPORTED SYSTEMS
#
# No platform flag on purpose: the core is plain C++17 built from source, so the
# module is offered on every RetroPie platform: Raspberry Pi Zero / 1 (armv6),
# Zero 2 / 3 (armv7 / armv8), 4 and 5 (32-bit or 64-bit) and x86 / x86_64.
# Older images (Buster, used on the Pi Zero / Pi 3) are handled in sources and
# build: CMake 3.13 and GCC 8.
################################

################################
# MEDIA PACK
#
# gamelist.xml + media/emulationstation (<rom>.png, <rom>_logo.png, <rom>.mp4)
# taken from the colortvgame folder of this repository and branch.
################################
_ctg_media_repo="https://github.com/DTEAM-1/test"
_ctg_media_branch="main"
_ctg_media_dir="colortvgame"

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
_ctg_selector="game_selector"
_ctg_selector_old="Game Selector"
# standardized file name of each selector, indexed by its content ID (byte 4 of the file)
_ctg_names=("tennis_variant_singles" "tennis_variant_doubles" "tennis_original_singles" "tennis_original_doubles" "hockey_variant_singles" "hockey_variant_doubles" "hockey_original_singles" "hockey_original_doubles" "volleyball_variant_singles" "volleyball_variant_doubles" "volleyball_original_singles" "volleyball_original_doubles" "pingpong_singles" "pingpong_doubles" "shooting" "racing112")

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

    # Buster (Pi Zero / Pi 3 images) ships CMake 3.13; the project asks for 3.16
    # but uses nothing newer than 3.13, so lower the requirement only there.
    local cmv
    cmv="$(cmake --version 2>/dev/null | sed -n 's/^cmake version \([0-9]*\.[0-9]*\).*/\1/p')"
    if [[ -n "$cmv" ]] && compareVersions "$cmv" lt 3.16; then
        sed -i 's/^cmake_minimum_required(VERSION 3\.1[6-9][^)]*)/cmake_minimum_required(VERSION 3.13)/' CMakeLists.txt
        echo "CMake $cmv: minimum version lowered to 3.13 in CMakeLists.txt"
    fi

    # media pack: only the colortvgame folder of the repository archive is extracted.
    # Plain curl on purpose: RetroPie's download() records a failure as an install
    # error, and a missing media pack must never stop the core from installing.
    local url="${CTG_MEDIA_URL:-$_ctg_media_repo/archive/refs/heads/$_ctg_media_branch.tar.gz}"
    local tgz="$md_build/media_pack.tar.gz"
    rm -rf "$md_build/media_pack" "$tgz"
    mkdir -p "$md_build/media_pack"
    if curl -sSfL --connect-timeout 10 --retry 2 -o "$tgz" "$url" \
        && tar -xzf "$tgz" -C "$md_build/media_pack" --strip-components=1 \
            "${_ctg_media_repo##*/}-$_ctg_media_branch/$_ctg_media_dir" \
        && [[ -f "$md_build/media_pack/$_ctg_media_dir/gamelist.xml" ]]; then
        echo "Media pack: $(find "$md_build/media_pack/$_ctg_media_dir" -type f | wc -l) files from $_ctg_media_repo"
    else
        rm -rf "$md_build/media_pack"
        echo "!! Media pack could not be downloaded ($url): the core installs without gamelist and media"
    fi
    rm -f "$tgz"
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
    [[ -d "$md_build/media_pack/$_ctg_media_dir" ]] && md_ret_files+=("media_pack/$_ctg_media_dir")
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

# content ID of a .ctg selector (exactly 5 bytes, "CTG1" + ID 0-15); fails otherwise
function _ctg_id_lr-colortvgame() {
    local f="$1" id
    [[ "$(stat -c %s "$f" 2>/dev/null)" == 5 ]] || return 1
    [[ "$(head -c 4 "$f")" == "CTG1" ]] || return 1
    id="$(od -An -tu1 -j4 -N1 "$f" | tr -d ' ')"
    [[ "$id" =~ ^[0-9]+$ ]] && (( id <= 15 )) || return 1
    echo "$id"
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
    # .ctg SELECTORS: 5 bytes each ("CTG1" + content ID), not ROMs.
    # They are installed under standardized names chosen from the ID stored in
    # the file, not from the upstream file name. Selectors already in the ROM
    # folder under another name (e.g. the upstream long names installed by an
    # earlier version of this module) are renamed, or removed when the
    # standardized file already exists. An existing standardized file is never
    # overwritten. game_selector.ctg is a copy of a valid selector (ID 2): if
    # the per-ROM key below is ever lost, it starts Tennis instead of failing.
    ################################
    local f id dst dir="$romdir/$sys"
    [[ -f "$dir/$_ctg_selector_old.ctg" ]] && \
        { [[ -e "$dir/$_ctg_selector.ctg" ]] && rm -f "$dir/$_ctg_selector_old.ctg" \
          || mv "$dir/$_ctg_selector_old.ctg" "$dir/$_ctg_selector.ctg"; }
    for f in "$dir"/*.ctg "$md_inst"/content/*.ctg; do
        [[ -f "$f" ]] || continue
        id="$(_ctg_id_lr-colortvgame "$f")" || continue
        dst="$dir/${_ctg_names[$id]}.ctg"
        [[ "$f" == "$dst" || "${f##*/}" == "$_ctg_selector.ctg" ]] && continue
        if [[ "$f" == "$dir/"* ]]; then
            [[ -e "$dst" ]] && rm -f "$f" || mv "$f" "$dst"
        else
            [[ -e "$dst" ]] || cp "$f" "$dst"
        fi
    done
    [[ -e "$dir/$_ctg_selector.ctg" ]] || cp "$dir/${_ctg_names[2]}.ctg" "$dir/$_ctg_selector.ctg"

    ################################
    # MEDIA PACK -> ROM folder
    # media/emulationstation is synced from the pack (pack files replace older
    # copies; extra files of your own are kept). gamelist.xml is installed when
    # the ROM folder has none; an existing one is never overwritten (it holds
    # EmulationStation data such as favorites): the new version is then written
    # next to it as gamelist.xml.rp-dist. playcount / lastplayed are removed
    # from the packaged gamelist.
    ################################
    local pack="$md_inst/$_ctg_media_dir"
    if [[ -d "$pack" ]]; then
        if [[ -d "$pack/media" ]]; then
            cp -Rf "$pack/media" "$dir/"
            echo "Media: $(find "$pack/media" -type f | wc -l) files synced to $dir/media"
        fi
        if [[ -f "$pack/gamelist.xml" ]]; then
            local gl="$dir/gamelist.xml"
            [[ -f "$gl" ]] && gl="$dir/gamelist.xml.rp-dist"
            xmlstarlet ed -d '//game/playcount' -d '//game/lastplayed' "$pack/gamelist.xml" > "$gl"
            if [[ "$gl" == *.rp-dist ]]; then
                echo "gamelist.xml already present in $dir: left untouched, new version saved as gamelist.xml.rp-dist"
            else
                echo "gamelist.xml installed in $dir"
            fi
        fi
    else
        echo "No media pack installed: gamelist and media skipped"
    fi
    chown -R "$__user":"$__group" "$dir"

    # per-ROM key of the old "Game Selector.ctg" name
    [[ -f "$configdir/all/emulators.cfg" ]] && \
        sed -i "/^${sys}_GameSelector[[:space:]]*=/d" "$configdir/all/emulators.cfg"

    iniConfig " = " '"' "$configdir/all/emulators.cfg"
    iniSet "$key" "$md_id-selector"
    chown "$__user":"$__group" "$configdir/all/emulators.cfg"

    echo ""
    echo "Launch lines installed ($md_conf_root/$sys/emulators.cfg):"
    cat "$md_conf_root/$sys/emulators.cfg"
    echo "Per-ROM key: $key = \"$md_id-selector\""
    echo ""
}
