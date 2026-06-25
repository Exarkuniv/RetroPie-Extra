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


# Script Provided by Nash - Updated by RapidEdwin08 20250311
# https://retropie.org.uk/forum/topic/36971/gamecube-wii-error-mario-part-5/2

# If no user is specified (for RetroPie below v4.8.9)
if [[ -z "$__user" ]]; then __user="$SUDO_USER"; [[ -z "$__user" ]] && __user="$(id -un)"; fi

rp_module_id="dolphin-rpi"
rp_module_desc="Gamecube/Wii Dolphin Modified from 5.0-4544 for Pi Users"
rp_module_help="ROM Extensions: .elf .dol .gcm .iso .rvz .wbfs .ciso .gcz .wad .dff\n\nCopy your Gamecube roms to $romdir/gc and Wii roms to $romdir/wii"
rp_module_licence="GPL2 https://github.com/gvx64/dolphin-rpi/blob/master/license.txt"
rp_module_repo="git https://github.com/gvx64/dolphin-rpi.git master"
rp_module_section="exp"
rp_module_flags=""
 
function depends_dolphin-rpi() {
    local depends=(cmake gcc-11 g++-11 pkg-config libasound2-dev libopenal-dev libevdev-dev libgtk2.0-dev qtbase5-private-dev libxxf86vm-dev x11proto-xinerama-dev)
 
    isPlatform "kms" && depends+=(xorg matchbox-window-manager)
 
    getDepends "${depends[@]}"
}
 
function sources_dolphin-rpi() {
    gitPullOrClone
    # Hide Font Error: Trying to access Windows-1252 fonts but they are not loaded. /Source/Core/Core/HW/EXI/EXI_DeviceIPL.cpp
    applyPatch "$md_data/01_font_alerts.diff"
}
 
function build_dolphin-rpi() {
    mkdir -p build
    cd build || return 1
    # use the bundled 'speexdsp' libs, distro versions before 1.2.1 trigger a 'cmake' error
    cmake .. -DCMAKE_C_COMPILER=gcc-11 -DCMAKE_CXX_COMPILER=g++-11 -DBUNDLE_SPEEX=ON -DENABLE_AUTOUPDATE=OFF -DENABLE_ANALYTICS=OFF  -DUSE_DISCORD_PRESENCE=O>    make clean || return 1
    make || return 1
    md_ret_require="$md_build/build/Binaries/dolphin-emu"
}
 
function install_dolphin-rpi() {
    #copy binaries to /opt/retropie/emulators/dolphin-rpi
    cd build/Binaries/ || return 1
    mkdir -p /opt/retropie/emulators/dolphin-rpi/
    mkdir -p /opt/retropie/emulators/dolphin-rpi/bin/
    mv dolphin-emu /opt/retropie/emulators/dolphin-rpi/bin/ || return 1
    mv dolphin-emu-nogui /opt/retropie/emulators/dolphin-rpi/bin/ || return 1
    #use $home/DolphinConfig5.0/ as the configuration/settings/save file directory
    cd .. || return 1
    mkdir -p $home/DolphinConfig5.0/
    mkdir -p $home/DolphinConfig5.0/Config/
    mv ../Data/Sys/GameSettings/ $home/DolphinConfig5.0/ || return 1
    mv ../Data/Sys/GC/ $home/DolphinConfig5.0/ || return 1
    mv ../Data/Sys/Wii/ $home/DolphinConfig5.0/ || return 1
    mv ../Data/Sys/Maps/ $home/DolphinConfig5.0/ || return 1
    mv ../Data/Sys/Resources/ $home/DolphinConfig5.0/ || return 1
    mv ../Data/Sys/Shaders/ $home/DolphinConfig5.0/ || return 1
    mv ../Data/Sys/Themes/ $home/DolphinConfig5.0/ || return 1
    mv ../Data/Sys/codehandler.bin $home/DolphinConfig5.0/ || return 1
    mv ../Data/Sys/totaldb.dsy $home/DolphinConfig5.0/ || return 1
    mv ../Data/Sys/wiitdb-de.txt $home/DolphinConfig5.0/ || return 1
    mv ../Data/Sys/wiitdb-en.txt $home/DolphinConfig5.0/ || return 1
    mv ../Data/Sys/wiitdb-es.txt $home/DolphinConfig5.0/ || return 1
    mv ../Data/Sys/wiitdb-fr.txt $home/DolphinConfig5.0/ || return 1
    mv ../Data/Sys/wiitdb-it.txt $home/DolphinConfig5.0/ || return 1
    mv ../Data/Sys/wiitdb-ja.txt $home/DolphinConfig5.0/ || return 1
    mv ../Data/Sys/wiitdb-ko.txt $home/DolphinConfig5.0/ || return 1
    mv ../Data/Sys/wiitdb-nl.txt $home/DolphinConfig5.0/ || return 1
    mv ../Data/Sys/wiitdb-pt.txt $home/DolphinConfig5.0/ || return 1
    mv ../Data/Sys/wiitdb-ru.txt $home/DolphinConfig5.0/ || return 1
    mv ../Data/Sys/wiitdb-zh_CN.txt $home/DolphinConfig5.0/ || return 1
    mv ../Data/Sys/wiitdb-zh_TW.txt $home/DolphinConfig5.0/ || return 1
}
 
function remove_dolphin-rpi() {
    rm -r $home/DolphinConfig5.0/GameSettings/
    rm -r $home/DolphinConfig5.0/Maps/
    rm -r $home/DolphinConfig5.0/Resources/
    rm -r $home/DolphinConfig5.0/Shaders/
    rm -r $home/DolphinConfig5.0/Themes/
    rm -r $home/DolphinConfig5.0/Config/
    rm $home/DolphinConfig5.0/codehandler.bin
    rm $home/DolphinConfig5.0/totaldb.dsy
    rm $home/DolphinConfig5.0/wiitdb-de.txt
    rm $home/DolphinConfig5.0/wiitdb-en.txt
    rm $home/DolphinConfig5.0/wiitdb-es.txt
    rm $home/DolphinConfig5.0/wiitdb-fr.txt
    rm $home/DolphinConfig5.0/wiitdb-it.txt
    rm $home/DolphinConfig5.0/wiitdb-ja.txt
    rm $home/DolphinConfig5.0/wiitdb-ko.txt
    rm $home/DolphinConfig5.0/wiitdb-nl.txt
    rm $home/DolphinConfig5.0/wiitdb-pt.txt
    rm $home/DolphinConfig5.0/wiitdb-ru.txt
    rm $home/DolphinConfig5.0/wiitdb-zh_CN.txt
    rm $home/DolphinConfig5.0/wiitdb-zh_TW.txt
#   Do not delete GC or Wii save file directories upon emulator uninstall
#    rm -r $home/DolphinConfig5.0/GC/
#    rm -r $home/DolphinConfig5.0/Wii/
#    rm -r $home/DolphinConfig5.0/

    # Remove Symbolic Link to Address Error: Could not find resource: /usr/local/share/dolphin-emu/sys/Resources/nobanner.png
    rm -Rf /usr/local/share/dolphin-emu
}
 
function configure_dolphin-rpi() {
    mkRomDir "gc"
    mkRomDir "wii"
 
    local launch_prefix
    isPlatform "kms" && launch_prefix="XINIT-WM:"
 
    addEmulator 0 "$md_id" "gc" "$launch_prefix$md_inst/bin/dolphin-emu-nogui -e %ROM% -u $home/DolphinConfig5.0/"
    addEmulator 1 "$md_id-gui" "gc" "$launch_prefix$md_inst/bin/dolphin-emu -b -e %ROM% -u $home/DolphinConfig5.0/"
    addEmulator 2 "$md_id-editor" "gc" "XINIT-WMC:$md_inst/bin/dolphin-emu -u $home/DolphinConfig5.0/"
    #addEmulator 3 "$md_id-editor-hotkeys" "gc" "XINIT-WMC:$md_inst/bin/dolphin-emu-qt2 -u $home/DolphinConfig5.0/"
    addEmulator 0 "$md_id" "wii" "$launch_prefix$md_inst/bin/dolphin-emu-nogui -e %ROM% -u $home/DolphinConfig5.0/"
    addEmulator 1 "$md_id-gui" "wii" "$launch_prefix$md_inst/bin/dolphin-emu -b -e %ROM% -u $home/DolphinConfig5.0/"
    addEmulator 2 "$md_id-editor" "wii" "XINIT-WMC:$md_inst/bin/dolphin-emu -u $home/DolphinConfig5.0/"
    #addEmulator 3 "$md_id-editor-hotkeys" "wii" "XINIT-WMC:$md_inst/bin/dolphin-emu-qt2 -u $home/DolphinConfig5.0/"
 
    addSystem "gc"
    addSystem "wii"
 
    [[ "$md_mode" == "remove" ]] && return
 
    # preset options used for Raspberry Pi 4 (Bookworm) - modify for your build as desired
   cat >"$home/DolphinConfig5.0/Config/Dolphin.ini" <<_EOF_
[Core]
OverclockEnable = False
EnableCheats = False
GFXBackend = Vulkan
CPUCore = 4
Fastmem = True
CPUThread = True
SyncOnSkipIdle = True
FPRF = False
AccurateNaNs = False
AudioLatency = 20
AutoDiscChange = True
[Display]
FullscreenDisplayRes = Auto
Fullscreen = True
RenderToMain = True
KeepWindowOnTop = True
[Interface]
ConfirmStop = False
[General]
ISOPath0 = "$home/RetroPie/roms/gc"
ISOPath1 = "$home/RetroPie/roms/wii"
ISOPaths = 2
WiiSDCardPath = $home/DolphinConfig5.0/Wii/sd.raw
_EOF_

    # Complimentary RE4 INI options - modify for your version as desired
    # G4BD08  Resident Evil 4 (PAL)
    # G4BE08  Resident Evil 4 (NTSC-U)
    # G4BP08  Resident Evil 4 (PAL)
    # RB4E08  Resident Evil 4: Wii Edition (NTSC-U)
    # RB4P08  Resident Evil 4: Wii Edition (PAL)
    # RB4X08  Resident Evil 4: Wii Edition (PAL) 
   if [ ! -f $home/DolphinConfig5.0/GameSettings/G4BE08.ini ]; then cat >"$home/DolphinConfig5.0/GameSettings/G4BE08.ini" <<_EOF_; fi
# G4BE08 - Resident Evil 4 (NTSC-U)
[Core]
GFXBackend = Vulkan
CPUThread = True
EmulationSpeed = 1.
SyncGPU = True
[Display]
Fullscreen = True
[Video_Hacks]
VISkip = True
[Video_Hardware]
VSync = False
[Video_Settings]
AspectRatio = 3
_EOF_

   chown -R $__user:$__user "$home/DolphinConfig5.0"
   
   # Symbolic Link to Address Error: Could not find resource: /usr/local/share/dolphin-emu/sys/Resources/nobanner.png
   if [ ! -d /usr/local/share/dolphin-emu ]; then sudo mkdir /usr/local/share/dolphin-emu; fi
   if [ ! -d /usr/local/share/dolphin-emu/sys ]; then sudo mkdir /usr/local/share/dolphin-emu/sys; fi
   if [ ! -d /usr/local/share/dolphin-emu/sys/Resources ]; then sudo ln -s $home/DolphinConfig5.0/Resources /usr/local/share/dolphin-emu/sys/Resources; fi
}