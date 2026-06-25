#!/usr/bin/env bash

# OpenJKDF2 RetroPie Installation Script (X11-only version)
# For Raspberry Pi 5 (Bookworm) - Stable X11 implementation

rp_module_id="openjkdf2"
rp_module_desc="Jedi Knight: Dark Forces II + MOTS Expansion"
rp_module_licence="GPL2 https://raw.githubusercontent.com/shinyquagsire23/OpenJKDF2/master/LICENSE"
rp_module_repo="git https://github.com/shinyquagsire23/OpenJKDF2.git"
rp_module_section="exp"
rp_module_flags="!all rpi5"

function depends_openjkdf2() {
    local depends=(
        libssl-dev build-essential libsdl2-dev libopenal-dev
        libopusfile-dev libpng-dev zlib1g-dev libbz2-de	libgtk-3-dev libglew-dev
        python3-full python3-venv mesa-utils xorg xinit
        openbox xserver-xorg-input-evdev xserver-xorg-input-libinput
    )
    getDepends "${depends[@]}"
}

function sources_openjkdf2() {
    gitPullOrClone
    
    python3 -m venv "$md_build/venv"
    source "$md_build/venv/bin/activate"
    "$md_build/venv/bin/pip" install cogapp
}

function build_openjkdf2() {
    source "$md_build/venv/bin/activate"
    
    cmake -S . -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -DFEATURE_EDITOR=OFF \
        -DFEATURE_LAUNCHER=OFF \
        -DFEATURE_NETWORKING=OFF \
        -DTARGET_USE_OPENGL=ON \
        -DTARGET_USE_SDL2=ON
    
    cmake --build build -j$(nproc) || return 1
    md_ret_require="$md_build/build/openjkdf2"
}

function install_openjkdf2() {
    md_ret_files=(
        'build/openjkdf2'
        'README.md'
        'LICENSE.md'
    )
}

function configure_openjkdf2() {
    mkRomDir "ports/openjkdf2"
    mkRomDir "ports/openjkdf2/mots"
    
    # Create launcher scripts
    cat > "$md_inst/openjkdf2-launcher.sh" << _EOF_
#!/bin/bash
cd "$md_inst"
export OPENJKDF2_ROOT="$romdir/ports/openjkdf2"
export MESA_GL_VERSION_OVERRIDE=3.3
export MESA_GLSL_VERSION_OVERRIDE=330
export SDL_VIDEODRIVER=x11

# Create minimal Openbox config
mkdir -p "$md_conf_root/openjkdf2"
cat > "$md_conf_root/openjkdf2/rc.xml" << _OB_CFG_
<openbox_config xmlns="http://openbox.org/3.4/rc">
  <applications>
    <application class="*">
      <decor>no</decor>
      <focus>yes</focus>
      <desktop>all</desktop>
      <layer>below</layer>
      <maximized>true</maximized>
    </application>
  </applications>
</openbox_config>
_OB_CFG_

# Launch through Openbox
openbox --config-file "$md_conf_root/openjkdf2/rc.xml" &
sleep 1
./openjkdf2
killall openbox
_EOF_

    cat > "$md_inst/openjkmots-launcher.sh" << _EOF_
#!/bin/bash
cd "$md_inst"
export OPENJKDF2_ROOT="$romdir/ports/openjkdf2"
export OPENJKMOTS_ROOT="$romdir/ports/openjkdf2/mots"
export MESA_GL_VERSION_OVERRIDE=3.3
export MESA_GLSL_VERSION_OVERRIDE=330
export SDL_VIDEODRIVER=x11

# Create minimal Openbox config
mkdir -p "$md_conf_root/openjkdf2"
cat > "$md_conf_root/openjkdf2/rc.xml" << _OB_CFG_
<openbox_config xmlns="http://openbox.org/3.4/rc">
  <applications>
    <application class="*">
      <decor>no</decor>
      <focus>yes</focus>
      <desktop>all</desktop>
      <layer>below</layer>
      <maximized>true</maximized>
    </application>
  </applications>
</openbox_config>
_OB_CFG_

# Launch through Openbox
openbox --config-file "$md_conf_root/openjkdf2/rc.xml" &
sleep 1
./openjkdf2 -mots
killall openbox
_EOF_
    
    chmod +x "$md_inst/openjkdf2-launcher.sh"
    chmod +x "$md_inst/openjkmots-launcher.sh"
    
    # Add ports with XINIT prefix
    addPort "$md_id" "openjkdf2" "Jedi Knight: Dark Forces II" "XINIT:$md_inst/openjkdf2-launcher.sh -- :0 -nocursor -keeptty"
    addPort "$md_id" "openjkmots" "Jedi Knight: Mysteries of the Sith" "XINIT:$md_inst/openjkmots-launcher.sh -- :0 -nocursor -keeptty"
    
    # Create documentation
    cat > "$md_inst/README-RETROPIE.txt" << _EOF_
=== WORKING Installation ===
1. Copy original game files to:
   - Base game: $romdir/ports/openjkdf2/
   - MOTS expansion: $romdir/ports/openjkdf2/mots/

Required files for base game:
- JKDF2.EXE
- ASSETS/
- GOOBERS/
- LEVELS/
- MOVIES/
- MUSIC/
- TEXTURES/

Required files for MOTS expansion:
- JKDF2.EXE (from MOTS)
- ASSETS/
- LEVELS/
- MOVIES/
- MUSIC/
- TEXTURES/

Controls:
- Mouse should work normally
- Alt+Enter to toggle fullscreen
- F10 to exit game

Note: Both installations share the same executable but use different data directories.
_EOF_
}