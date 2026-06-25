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


rp_module_id="supermodel-svn"
rp_module_desc="Sega supermodel 3 version from sourceforge"
rp_module_help="\
WARNING: Still under construction\n\n\
Notes:\n\
- Created in such a way so it should not conflict with other supermodel installs\n\
- Select a good video mode in the RetroPie boot menu to get fullscreen\n\n\
ROM Extensions: .zip\n\n\
Copy your games to $romdir/supermodel\n\n\
Supermodel emulator directories and files are added in:\n\
~/RetroPie/roms/supermodel/model3emu/svn\n\
(NVRAM, Saves, Supermodel.ini and Supermodel.log)\n\n\
Add these lines to your Supermodel.ini,\n\
and alter them to your needs:\n\
XResolution=800 ; Default value 496\n\
YResolution=600 ; Default value 384\n\
FullScreen=0\n\
WideScreen=0\n\
Stretch=1\n\
WideBackground=0\n\
\n\n\
"
rp_module_section="exp"
rp_module_flags=""

function depends_supermodel-svn() {
    getDepends xorg subversion libsdl2-dev libsdl2-net-dev
}

function sources_supermodel-svn() {
    svn checkout https://svn.code.sf.net/p/model3emu/code/trunk $md_build
}

function build_supermodel-svn() {
    cd $md_build || return 1
    sed -i 's/texture2DLod/texture2D/g'  Src/Graphics/New3D/R3DShaderTriangles.h
    sed -i 's/ARCH =/ARCH = \-march=native/g'  /home/pi/model3emu-code/Makefiles/Rules.inc
    cp Makefiles/Makefile.UNIX Makefile
    make || return 1
}

function install_supermodel-svn() {
    md_ret_files=(        
        'bin'
        'Config'
    )
    #note: command "mv" and "cp" won't work here, you get a "cannot stat error" in this function
}

function configure_supermodel-svn() {
    mkRomDir "supermodel"
    mkRomDir "supermodel/model3emu"
    mkRomDir "supermodel/model3emu/svn"
    mkRomDir "supermodel/model3emu/svn/NVRAM"
    mkRomDir "supermodel/model3emu/svn/Saves"    

    addEmulator 0 "Supermodel-svn-normal" "supermodel" "XINIT:pushd /opt/retropie/emulators/supermodel-svn;/opt/retropie/emulators/supermodel-svn/bin/supermodel -legacy3d -sound-volume=50 -music-volume=60 -no-vsync -no-throttle -no-dsb -load-state=%ROM%.st0 %ROM%"
    addEmulator 0 "Supermodel-svn-40-hz-PPC-Underclock" "supermodel" "XINIT:pushd /opt/retropie/emulators/supermodel-svn;/opt/retropie/emulators/supermodel-svn/bin/supermodel -ppc-frequency=40 -legacy3d -sound-volume=50 -music-volume=60 -no-vsync -no-throttle -no-dsb -load-state=%ROM%.st0 %ROM%"
    addEmulator 0 "Supermodel-svn-45-hz-PPC-Underclock" "supermodel" "XINIT:pushd /opt/retropie/emulators/supermodel-svn;/opt/retropie/emulators/supermodel-svn/bin/supermodel -ppc-frequency=45 -legacy3d -sound-volume=50 -music-volume=60 -no-vsync -no-throttle -no-dsb -load-state=%ROM%.st0 %ROM%"
    addEmulator 0 "Supermodel-svn-48-hz-PPC-Underclock" "supermodel" "XINIT:pushd /opt/retropie/emulators/supermodel-svn;/opt/retropie/emulators/supermodel-svn/bin/supermodel -ppc-frequency=48 -legacy3d -sound-volume=50 -music-volume=60 -no-vsync -no-throttle -no-dsb -load-state=%ROM%.st0 %ROM%"


    addSystem "supermodel" "Sega supermodel 3" ".zip"

    #to prevent nested links within the directories, previously created links are removed before creating new ones !
    rm "$md_inst/NVRAM" 2>&-
    rm "$md_inst/Saves" 2>&-

    ln -sv "$romdir/supermodel/model3emu/svn/NVRAM" "$md_inst/NVRAM"
    ln -sv "$romdir/supermodel/model3emu/svn/Saves" "$md_inst/Saves"
    ln -sv "$romdir/supermodel/model3emu/svn/Supermodel.log" "$md_inst/Supermodel.log" 2>&-

    #check if file exists and check if file is a not symlink
    #if so, then : 
    #- move the Supermodel.ini to the desired directory
    #- fix the permissions of that file to the normal user
    #- make a symlink to that file
    if [[ -f "$md_inst/Config/Supermodel.ini" ]] && [[ ! -L "$md_inst/Config/Supermodel.ini" ]]; then
    mv "$md_inst/Config/Supermodel.ini" "$romdir/supermodel/model3emu/svn/Supermodel.ini" || return 1
    chown $__user:$__group -R "$romdir/supermodel/model3emu/svn/Supermodel.ini"
    ln -sv "$romdir/supermodel/model3emu/svn/Supermodel.ini" "$md_inst/Config/Supermodel.ini"
    fi
}