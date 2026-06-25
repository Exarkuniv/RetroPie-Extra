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
# Shared utility functions for RetroPie-Extra scriptmodules.
# Source this file from individual scriptmodules to reduce code duplication.

# Download Doom shareware and Freedoom WADs to the ports/doom directory.
# Usage: _download_doom_port_wads
function _download_doom_port_wads() {
    mkRomDir "ports"
    mkRomDir "ports/doom"
    if [[ ! -f "$romdir/ports/doom/doom1.wad" ]]; then
        wget "$__archive_url/doom1.wad" -O "$romdir/ports/doom/doom1.wad"
    fi

    if [[ ! -f "$romdir/ports/doom/freedoom1.wad" ]]; then
        wget "https://github.com/freedoom/freedoom/releases/download/v0.12.1/freedoom-0.12.1.zip"
        unzip freedoom-0.12.1.zip
        mv freedoom-0.12.1/*.wad "$romdir/ports/doom"
        rm -rf freedoom-0.12.1
        rm freedoom-0.12.1.zip
    fi
}

# Download Doom shareware and Freedoom WADs to the doom system directory.
# Usage: _download_doom_system_wads
function _download_doom_system_wads() {
    mkRomDir "doom"
    if [[ ! -f "$romdir/doom/doom1.wad" ]]; then
        wget "$__archive_url/doom1.wad" -O "$romdir/doom/doom1.wad"
    fi

    if [[ ! -f "$romdir/doom/freedoom1.wad" ]]; then
        wget "https://github.com/freedoom/freedoom/releases/download/v0.12.1/freedoom-0.12.1.zip"
        unzip freedoom-0.12.1.zip
        mv freedoom-0.12.1/*.wad "$romdir/doom"
        rm -rf freedoom-0.12.1
        rm freedoom-0.12.1.zip
    fi
}

# Register Doom WAD files as ports for a given engine.
# Checks for common WAD files and adds port entries for each one found.
#
# Usage: _add_doom_wad_ports "engine_prefix" "Engine Name" "command"
#   engine_prefix: short name used for port IDs (e.g. "chocolate", "crispy", "eternity")
#   engine_name:   display name prefix (e.g. "Chocolate", "Crispy", "Eternity")
#   command:       the executable command (e.g. "$md_inst/crispy-doom")
#
# Example: _add_doom_wad_ports "crispy" "Crispy" "$md_inst/crispy-doom"
function _add_doom_wad_ports() {
    local prefix="$1"
    local name="$2"
    local cmd="$3"

    local wad_dir="$romdir/ports/doom"

    if [[ -f "$wad_dir/doom1.wad" ]]; then
        chown $user:$user "$wad_dir/doom1.wad"
        addPort "$md_id" "${prefix}-doom1" "$name Doom Shareware" "$cmd -iwad $wad_dir/doom1.wad"
    fi

    if [[ -f "$wad_dir/doom.wad" ]]; then
        chown $user:$user "$wad_dir/doom.wad"
        addPort "$md_id" "${prefix}-doom" "$name Doom Registered" "$cmd -iwad $wad_dir/doom.wad"
    fi

    if [[ -f "$wad_dir/freedoom1.wad" ]]; then
        chown $user:$user "$wad_dir/freedoom1.wad"
        addPort "$md_id" "${prefix}-freedoom1" "$name Free Doom: Phase 1" "$cmd -iwad $wad_dir/freedoom1.wad"
    fi

    if [[ -f "$wad_dir/freedoom2.wad" ]]; then
        chown $user:$user "$wad_dir/freedoom2.wad"
        addPort "$md_id" "${prefix}-freedoom2" "$name Free Doom: Phase 2" "$cmd -iwad $wad_dir/freedoom2.wad"
    fi

    if [[ -f "$wad_dir/doom2.wad" ]]; then
        chown $user:$user "$wad_dir/doom2.wad"
        addPort "$md_id" "${prefix}-doom2" "$name Doom II: Hell on Earth" "$cmd -iwad $wad_dir/doom2.wad"
    fi

    if [[ -f "$wad_dir/doomu.wad" ]]; then
        chown $user:$user "$wad_dir/doomu.wad"
        addPort "$md_id" "${prefix}-doomu" "$name Ultimate Doom" "$cmd -iwad $wad_dir/doomu.wad"
    fi

    if [[ -f "$wad_dir/tnt.wad" ]]; then
        chown $user:$user "$wad_dir/tnt.wad"
        addPort "$md_id" "${prefix}-doomtnt" "$name Final Doom - TNT: Evilution" "$cmd -iwad $wad_dir/tnt.wad"
    fi

    if [[ -f "$wad_dir/plutonia.wad" ]]; then
        chown $user:$user "$wad_dir/plutonia.wad"
        addPort "$md_id" "${prefix}-doomplutonia" "$name Final Doom - The Plutonia Experiment" "$cmd -iwad $wad_dir/plutonia.wad"
    fi
}

# Register Heretic/Hexen/Strife WAD files as ports for chocolate-doom style engines.
# These WADs use separate binaries (e.g. chocolate-heretic, chocolate-hexen).
#
# Usage: _add_heretic_hexen_strife_ports "engine_prefix" "Engine Name" "base_cmd_prefix"
#   engine_prefix:  short name used for port IDs (e.g. "chocolate", "eternity")
#   engine_name:    display name prefix (e.g. "Chocolate", "Eternity")
#   heretic_cmd:    command for heretic (e.g. "$md_inst/chocolate-heretic")
#   hexen_cmd:      command for hexen (e.g. "$md_inst/chocolate-hexen") - optional
#   strife_cmd:     command for strife (e.g. "$md_inst/chocolate-strife") - optional
#
# Example: _add_heretic_hexen_strife_ports "chocolate" "Chocolate" "$md_inst/chocolate-heretic" "$md_inst/chocolate-hexen" "$md_inst/chocolate-strife"
function _add_heretic_hexen_strife_ports() {
    local prefix="$1"
    local name="$2"
    local heretic_cmd="$3"
    local hexen_cmd="$4"
    local strife_cmd="$5"

    local wad_dir="$romdir/ports/doom"

    if [[ -n "$heretic_cmd" ]]; then
        if [[ -f "$wad_dir/heretic1.wad" ]]; then
            chown $user:$user "$wad_dir/heretic1.wad"
            addPort "$md_id" "${prefix}-heretic1" "$name Heretic Shareware" "$heretic_cmd -iwad $wad_dir/heretic1.wad"
        fi

        if [[ -f "$wad_dir/heretic.wad" ]]; then
            chown $user:$user "$wad_dir/heretic.wad"
            addPort "$md_id" "${prefix}-heretic" "$name Heretic Registered" "$heretic_cmd -iwad $wad_dir/heretic.wad"
        fi
    fi

    if [[ -n "$hexen_cmd" ]]; then
        if [[ -f "$wad_dir/hexen.wad" ]]; then
            chown $user:$user "$wad_dir/hexen.wad"
            addPort "$md_id" "${prefix}-hexen" "$name Hexen" "$hexen_cmd -iwad $wad_dir/hexen.wad"
        fi

        if [[ -f "$wad_dir/hexdd.wad" && -f "$wad_dir/hexen.wad" ]]; then
            chown $user:$user "$wad_dir/hexdd.wad"
            addPort "$md_id" "${prefix}-hexdd" "$name Hexen: Deathkings of the Dark Citadel" "$hexen_cmd -iwad $wad_dir/hexen.wad -file $wad_dir/hexdd.wad"
        fi
    fi

    if [[ -n "$strife_cmd" ]]; then
        if [[ -f "$wad_dir/strife1.wad" ]]; then
            chown $user:$user "$wad_dir/strife1.wad"
            addPort "$md_id" "${prefix}-strife1" "$name Strife" "$strife_cmd -iwad $wad_dir/strife1.wad"
        fi
    fi
}

# Build a libretro core using Makefile.libretro.
# Usage: _build_libretro_core "core_name"
#   core_name: name of the .so output (without _libretro.so suffix)
#
# Example: _build_libretro_core "2048"
function _build_libretro_core() {
    local core_name="$1"
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="$md_build/${core_name}_libretro.so"
}

# Configure a libretro core as a port.
# Usage: _configure_libretro_port "port_name" "display_name" "core_file"
#   port_name:    short name for the port (e.g. "2048", "craft")
#   display_name: human-readable name (e.g. "2048", "Craft")
#   core_file:    .so filename (e.g. "2048_libretro.so")
#
# Example: _configure_libretro_port "2048" "2048" "2048_libretro.so"
function _configure_libretro_port() {
    local port_name="$1"
    local display_name="$2"
    local core_file="$3"

    setConfigRoot "ports"
    addPort "$md_id" "$port_name" "$display_name" "$md_inst/$core_file"
    ensureSystemretroconfig "ports/$port_name"
}

# Configure a libretro core as a system emulator.
# Usage: _configure_libretro_system "system" "core_file" [is_default] [system_name] [extensions]
#   system:       system name (e.g. "megadrive", "uzebox")
#   core_file:    .so filename (e.g. "blastem_libretro.so")
#   is_default:   1 or 0, whether this is the default emulator (default: 1)
#   system_name:  display name for the system (optional, passed to addSystem)
#   extensions:   file extensions (optional, passed to addSystem)
#
# Example: _configure_libretro_system "megadrive" "blastem_libretro.so"
# Example: _configure_libretro_system "uzebox" "uzem_libretro.so" 1 "Uzem" ".uze .zip"
function _configure_libretro_system() {
    local system="$1"
    local core_file="$2"
    local is_default="${3:-1}"
    local system_name="$4"
    local extensions="$5"

    mkRomDir "$system"
    ensureSystemretroconfig "$system"

    addEmulator "$is_default" "$md_id" "$system" "$md_inst/$core_file"
    if [[ -n "$system_name" ]]; then
        addSystem "$system" "$system_name" "$extensions"
    else
        addSystem "$system"
    fi
}
