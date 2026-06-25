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


rp_module_id="supermodel-mechafatnick"
rp_module_desc="Sega supermodel 3 version by Mechafatnick and Pi-friendly"
rp_module_help="\
WARNING: Still under construction\n\n\
Notes:\n\
- Created in such a way so it should not conflict with other supermodel installs\n\
- Select a good video mode in the RetroPie boot menu to get fullscreen\n\n\
ROM Extensions: .zip\n\n\
Copy your games to $romdir/supermodel\n\n\
Supermodel emulator directories and files are added in:\n\
~/RetroPie/roms/supermodel/model3emu/mechafatnick\n\
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

function depends_supermodel-mechafatnick() {
    getDepends xorg subversion libsdl2-dev libsdl2-net-dev
}

function sources_supermodel-mechafatnick() {
    downloadAndExtract https://github.com/Mechafatnick/SuperModelPi/archive/refs/heads/master.zip $md_build
}

function build_supermodel-mechafatnick() {
    cd $md_build/SuperModelPi-master || return 1
    cp Makefiles/Makefile.UNIX Makefile
    make || return 1
}

function install_supermodel-mechafatnick() {
    #note: it should remove all files in $md_inst if there are any, so no need to remove links or files
    #note: command "mv" and "cp" won't work here, you get a "cannot stat error" in this function
    #prevent an error if the NVRAM and Saves directory are not in the source!
    if [[ -d "$md_build/SuperModelPi-master/NVRAM" ]] && [[ -d "$md_build/SuperModelPi-master/Saves" ]] ;then
    md_ret_files=(        
        'SuperModelPi-master/bin/supermodel'
        'SuperModelPi-master/Config'
        'SuperModelPi-master/NVRAM'
        'SuperModelPi-master/Saves'
    )
    else
    md_ret_files=(        
        'SuperModelPi-master/bin/supermodel'
        'SuperModelPi-master/Config'
    ) 
    fi
}

function configure_supermodel-mechafatnick() {
    mkRomDir "supermodel"
    mkRomDir "supermodel/model3emu"
    mkRomDir "supermodel/model3emu/mechafatnick"
    mkRomDir "supermodel/model3emu/mechafatnick/NVRAM"
    mkRomDir "supermodel/model3emu/mechafatnick/Saves"

    addEmulator 0 "Supermodel-mechafatnick-496x384" "supermodel" "XINIT:pushd /opt/retropie/emulators/supermodel-mechafatnick;./supermodel -res=496,384 %ROM%"
    addEmulator 0 "Supermodel-mechafatnick-800x600" "supermodel" "XINIT:pushd /opt/retropie/emulators/supermodel-mechafatnick;./supermodel -res=800,600 %ROM%"
    addEmulator 0 "Supermodel-mechafatnick-1024x768" "supermodel" "XINIT:pushd /opt/retropie/emulators/supermodel-mechafatnick;./supermodel -res=1024,768 %ROM%"
  
    addEmulator 0 "TEST auto resolution" "supermodel" "XINIT:pushd /opt/retropie/emulators/supermodel-mechafatnick;./supermodel -res=%XRES%,%YRES% %ROM%"

    addSystem "supermodel" "Sega supermodel 3" ".zip"

    #using "sudo ./retropie_packages.sh supermodel-mechafatnick install" for testing this function,
    #you have to prevent nested links within the linked directories !
    #if the link NVRAM doesn't exist, others will too, like: Saves,bin/Supermodel.ini and Supermodel.log
    #then we can assume the installed directories are in place and we can move them and create symlinks
    #else we do nothing otherwise we are going to push links into links!
    if [[ ! -L "$md_inst/NVRAM" ]];then
    #move and update the files
    mv $md_inst/NVRAM/* $romdir/supermodel/model3emu/mechafatnick/NVRAM 2>&-
    mv $md_inst/Saves/* $romdir/supermodel/model3emu/mechafatnick/Saves 2>&-
    #we have to remove those directories otherwise we get nested links when we create the links
    rm -r $md_inst/NVRAM
    rm -r $md_inst/Saves
    #we want to make sure we make a backup of Supermodel.ini if it exists, remove an old Supermodel.ini.old first
    #then move the existing Supermodel.ini to Supermodel.ini.old
    rm $romdir/supermodel/model3emu/mechafatnick/Supermodel.ini.old 2>&-
    mv $romdir/supermodel/model3emu/mechafatnick/Supermodel.ini $romdir/supermodel/model3emu/mechafatnick/Supermodel.ini.old 2>&-
    mv $md_inst/Config/Supermodel.ini  $romdir/supermodel/model3emu/mechafatnick/Supermodel.ini || return 1
    #fix permissions
    chown $__user:$__group -R "$romdir/supermodel/model3emu/mechafatnick"
    #make symlinks
    ln -sv $romdir/supermodel/model3emu/mechafatnick/NVRAM $md_inst/NVRAM
    ln -sv $romdir/supermodel/model3emu/mechafatnick/Saves $md_inst/Saves
    ln -sv $romdir/supermodel/model3emu/mechafatnick/Supermodel.ini $md_inst/Config/Supermodel.ini
    ln -sv $romdir/supermodel/model3emu/mechafatnick/Supermodel.log $md_inst/Supermodel.log 2>&-
    fi
}