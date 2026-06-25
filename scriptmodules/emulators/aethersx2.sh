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


rp_module_id="aethersx2"
rp_module_desc="PS2 emu - AetherSX2"
rp_module_help="ROM Extensions: .iso .chd\n\nCopy your PS2 roms to $romdir/ps2 copy your bios files to $biosdir/ps2. anywhere else will not work. You need to add kernel=kernel8.img to /boot/firmware/config.txt at the end"
rp_module_licence="PROP"
rp_module_repo="git https://github.com/retropieuser/aethersx2.git main"
rp_module_section="exp"
rp_module_flags="!all 64bit"

function _get_vars_sx2() {
    declare -A path=(
        [onstart]="$configdir/all/runcommand-onstart.sh"
        [onend]="$configdir/all/runcommand-onend.sh"
    )

    local var
    for var in "${!path[@]}"; do
        echo "local $var=${path[$var]}"
    done
}

function depends_aethersx2() {
    local depends=(matchbox-window-manager xorg xserver-xorg-input-all mesa-vulkan-drivers pulseaudio pipewire-media-session-pulseaudio)

    getDepends ${depends[@]}
}

function sources_aethersx2() {
    gitPullOrClone
}

function install_aethersx2() {
    $(_get_vars_sx2)
    local file
    tar -xzvf AetherSX2-v1.5-3606.tar.gz -C "/opt/retropie/emulators/aethersx2" || return 1
    chmod +x /opt/retropie/emulators/aethersx2/AetherSX2-v1.5-3606/usr/bin/aethersx2
}

function configure_aethersx2() {
    $(_get_vars_sx2)
    # preserve original file versions
    local file
    for file in "$onend"; do
        if [[ -f "$file" && ! -f "$file.old.$md_id" ]]; then
            cp -v "$file" "$file.old.$md_id"
            chown $__user:$__group -R "$file.old.$md_id"
        fi
    done

    # getting it to write the command line thats needed
     if isPlatform "rpi"; then
        for file in "$onend"; do
            touch "$file"
            chown $__user:$__group -R "$file"
        done
     #the command that needs to be written
        local onend_text='rm /opt/retropie/configs/ps2/Config/cache/vulkan_pipelines.bin && rm /opt/retropie/configs/ps2/Config/cache/vulkan_shaders.bin && rm /opt/retropie/configs/ps2/Config/cache/vulkan_shaders.idx'

        # writing command to the correct file
        echo "$onend_text" >> "$onend"

    fi

    mkRomDir "ps2"
    
    local launch_prefix
    isPlatform "kms" && launch_prefix="XINIT-WM:"

    addEmulator 0 "$md_id" "ps2" "$launch_prefix$md_inst/AetherSX2-v1.5-3606/usr/bin/aethersx2 -nogui %ROM%"
    addSystem "ps2"

    [[ "$md_mode" == "remove" ]] && return

    moveConfigDir "$home/.config/aethersx2" "$md_conf_root/ps2/Config"
    mkUserDir "$md_conf_root/ps2/Config/inis"
    
    # Create the ps2 BIOs directory if it doesn't exist
    if [ ! -d "$biosdir/ps2" ]; then
        mkdir -p "$biosdir/ps2"
    fi
    chown $__user:$__group -R "$biosdir/ps2"
    # Create a symbolic link for BIOS
    if [ ! -L "$home/.config/aethersx2/bios" ]; then
        ln -s "$biosdir/ps2" "$home/.config/aethersx2/bios"
    fi
    
    # preset a few options on a first installation
    if [[ ! -f "$home/.config/aethersx2/inis/PCSX2.ini" ]]; then
        cat >"$home/.config/aethersx2/inis/PCSX2.ini" <<_EOF_
[UI]
SettingsVersion = 1
InhibitScreensaver = true
ConfirmShutdown = false
StartPaused = false
PauseOnFocusLoss = false
StartFullscreen = true
DoubleClickTogglesFullscreen = true
HideMouseCursor = false
RenderToSeparateWindow = false
HideMainWindowWhenRunning = false
DisableWindowResize = false
Theme = darkfusion
DisplayWindowGeometry = AdnQywADAAAAAAAAAAAAAAAAB38AAAQ3AAAABAAAABQAAAd7AAAEMwAAAAAAAAAAB4AAAAAEAAAAFAAAB3sAAAQz
MainWindowGeometry = AdnQywADAAAAAAAAAAAAAAAAB38AAAQ3AAAABAAAABQAAAd7AAAEMwAAAAAAAAAAB4AAAAAEAAAAFAAAB3sAAAQz
MainWindowState = AAAA/wAAAAD9AAAAAAAAB3gAAAP3AAAABAAAAAQAAAAIAAAACPwAAAABAAAAAgAAAAEAAAAOAHQAbwBvAGwAQgBhAHIAAAAAAP////8AAAAAAAAAAA==


[Folders]
Bios = ../../../../../../home/$user/RetroPie/BIOS/ps2
Snapshots = snaps
Savestates = sstates
MemoryCards = memcards
Logs = logs
Cheats = cheats
CheatsWS = cheats_ws
CheatsNI = cheats_ni
Cache = cache
Textures = textures
InputProfiles = inputprofiles


[EmuCore]
CdvdVerboseReads = false
CdvdDumpBlocks = false
CdvdShareWrite = false
EnablePatches = true
EnableCheats = false
EnablePINE = false
EnableWideScreenPatches = false
EnableNoInterlacingPatches = false
EnableRecordingTools = true
EnableGameFixes = true
SaveStateOnShutdown = false
EnableDiscordPresence = false
InhibitScreensaver = true
ConsoleToStdio = false
HostFs = false
BackupSavestate = true
SavestateZstdCompression = true
McdEnableEjection = true
McdFolderAutoManage = true
WarnAboutUnsafeSettings = true
BlockDumpSaveDirectory =
EnableFastBoot = true


[EmuCore/Speedhacks]
EECycleRate = 0
EECycleSkip = 0
fastCDVD = false
IntcStat = true
WaitLoop = true
vuFlagHack = true
vuThread = true
vu1Instant = true


[EmuCore/CPU]
FPU.DenormalsAreZero = true
FPU.FlushToZero = true
FPU.Roundmode = 3
AffinityControlMode = 0
VU.DenormalsAreZero = true
VU.FlushToZero = true
VU.Roundmode = 3


[EmuCore/CPU/Recompiler]
EnableEE = true
EnableIOP = true
EnableEECache = false
EnableVU0 = true
EnableVU1 = true
EnableFastmem = true
vuOverflow = true
vuExtraOverflow = false
vuSignOverflow = false
vuUnderflow = false
fpuOverflow = true
fpuExtraOverflow = false
fpuFullMode = false
fpuCorrectAddSub = true


[EmuCore/GS]
VsyncQueueSize = 2
FrameLimitEnable = true
VsyncEnable = 0
FramerateNTSC = 59.94
FrameratePAL = 50
SyncToHostRefreshRate = false
AspectRatio = Auto 4:3/3:2
FMVAspectRatioSwitch = Off
ScreenshotSize = 0
ScreenshotFormat = 0
ScreenshotQuality = 50
StretchY = 100
CropLeft = 0
CropTop = 0
CropRight = 0
CropBottom = 0
pcrtc_antiblur = true
disable_interlace_offset = false
pcrtc_offsets = false
pcrtc_overscan = false
IntegerScaling = false
UseDebugDevice = false
UseBlitSwapChain = false
disable_shader_cache = false
DisableDualSourceBlend = false
DisableFramebufferFetch = false
ThreadedPresentation = false
SkipDuplicateFrames = true
OsdShowMessages = true
OsdShowSpeed = false
OsdShowFPS = false
OsdShowCPU = false
OsdShowGPU = false
OsdShowResolution = false
OsdShowGSStats = false
OsdShowIndicators = true
OsdShowSettings = false
OsdShowInputs = false
OsdShowFrameTimes = false
OsdShowVersionInfo = false
HWSpinGPUForReadbacks = false
HWSpinCPUForReadbacks = false
paltex = false
autoflush_sw = true
preload_frame_with_gs_data = false
mipmap = true
UserHacks = false
UserHacks_align_sprite_X = false
UserHacks_AutoFlush = false
UserHacks_CPU_FB_Conversion = false
UserHacks_DisableDepthSupport = false
UserHacks_DisablePartialInvalidation = false
UserHacks_Disable_Safe_Features = false
UserHacks_merge_pp_sprite = false
UserHacks_WildHack = false
UserHacks_TextureInsideRt = false
fxaa = false
ShadeBoost = false
DumpReplaceableTextures = false
DumpReplaceableMipmaps = false
DumpTexturesWithFMVActive = false
DumpDirectTextures = true
DumpPaletteTextures = true
LoadTextureReplacements = false
LoadTextureReplacementsAsync = true
PrecacheTextureReplacements = false
linear_present_mode = 1
deinterlace_mode = 0
OsdScale = 100
Renderer = 14
upscale_multiplier = 1
mipmap_hw = -1
accurate_blending_unit = 1
crc_hack_level = -1
filter = 2
texture_preloading = 2
GSDumpCompression = 2
HWDownloadMode = 0
CASMode = 0
CASSharpness = 50
dithering_ps2 = 2
MaxAnisotropy = 0
extrathreads = 2
extrathreads_height = 4
TVShader = 0
UserHacks_SkipDraw_Start = 0
UserHacks_SkipDraw_End = 0
UserHacks_Half_Bottom_Override = -1
UserHacks_HalfPixelOffset = 0
UserHacks_round_sprite_offset = 0
UserHacks_TCOffsetX = 0
UserHacks_TCOffsetY = 0
UserHacks_CPUSpriteRenderBW = 0
UserHacks_CPUCLUTRender = 0
UserHacks_TriFilter = -1
OverrideTextureBarriers = -1
OverrideGeometryShaders = -1
ShadeBoost_Brightness = 50
ShadeBoost_Contrast = 50
ShadeBoost_Saturation = 50
png_compression_level = 1
VideoCaptureContainer = mp4
VideoCaptureCodec =
VideoCaptureBitrate = 6000
Adapter =
HWDumpDirectory =
SWDumpDirectory =


[SPU2/Mixing]
Interpolation = 5
FinalVolume = 100
VolumeAdjustC = 0
VolumeAdjustFL = 0
VolumeAdjustFR = 0
VolumeAdjustBL = 0
VolumeAdjustBR = 0
VolumeAdjustSL = 0
VolumeAdjustSR = 0
VolumeAdjustLFE = 0


[SPU2/Output]
OutputModule = cubeb
BackendName =
Latency = 100
SynchMode = 0
SpeakerConfiguration = 0
DplDecodingLevel = 0


[DEV9/Eth]
EthEnable = false
EthApi = Unset
EthDevice =
EthLogDNS = false
InterceptDHCP = false
PS2IP = 0.0.0.0
Mask = 0.0.0.0
Gateway = 0.0.0.0
DNS1 = 0.0.0.0
DNS2 = 0.0.0.0
AutoMask = true
AutoGateway = true
ModeDNS1 = Auto
ModeDNS2 = Auto


[DEV9/Eth/Hosts]
Count = 0


[DEV9/Hdd]
HddEnable = false
HddFile = DEV9hdd.raw
HddSizeSectors = 83886080


[EmuCore/Gamefixes]
VuAddSubHack = false
FpuMulHack = false
FpuNegDivHack = false
XgKickHack = false
EETimingHack = false
SoftwareRendererFMVHack = false
SkipMPEGHack = false
OPHFlagHack = false
DMABusyHack = false
VIFFIFOHack = false
VIF1StallHack = false
GIFFIFOHack = false
GoemonTlbHack = false
IbitHack = false
VUSyncHack = false
VUOverflowHack = false
BlitInternalFPSHack = false
FullVU0SyncHack = false


[EmuCore/Profiler]
Enabled = false
RecBlocks_EE = true
RecBlocks_IOP = true
RecBlocks_VU0 = true
RecBlocks_VU1 = true


[EmuCore/Debugger]
ShowDebuggerOnStart = false
AlignMemoryWindowStart = true
FontWidth = 8
FontHeight = 12
WindowWidth = 0
WindowHeight = 0
MemoryViewBytesPerRow = 16


[EmuCore/TraceLog]
Enabled = false
EE.bitset = 0
IOP.bitset = 0


[USB1]
Type = None


[USB2]
Type = None


[Achievements]
Enabled = false
TestMode = false
UnofficialTestMode = false
RichPresence = true
ChallengeMode = false
Leaderboards = true
Notifications = true
SoundEffects = true
PrimedIndicators = true


[Filenames]
BIOS =


[Framerate]
NominalScalar = 1
TurboScalar = 2
SlomoScalar = 0.5


[MemoryCards]
Slot1_Enable = true
Slot1_Filename = Mcd001.ps2
Slot2_Enable = true
Slot2_Filename = Mcd002.ps2
Multitap1_Slot2_Enable = false
Multitap1_Slot2_Filename = Mcd-Multitap1-Slot02.ps2
Multitap1_Slot3_Enable = false
Multitap1_Slot3_Filename = Mcd-Multitap1-Slot03.ps2
Multitap1_Slot4_Enable = false
Multitap1_Slot4_Filename = Mcd-Multitap1-Slot04.ps2
Multitap2_Slot2_Enable = false
Multitap2_Slot2_Filename = Mcd-Multitap2-Slot02.ps2
Multitap2_Slot3_Enable = false
Multitap2_Slot3_Filename = Mcd-Multitap2-Slot03.ps2
Multitap2_Slot4_Enable = false
Multitap2_Slot4_Filename = Mcd-Multitap2-Slot04.ps2


[Logging]
EnableSystemConsole = false
EnableFileLogging = false
EnableTimestamps = true
EnableVerbose = false
EnableEEConsole = false
EnableIOPConsole = false
EnableInputRecordingLogs = true
EnableControllerLogs = false


[InputSources]
Keyboard = true
Mouse = true
Sensor = false
SDL = true
SDLControllerEnhancedMode = false


[Hotkeys]
ToggleFullscreen = Keyboard/Alt & Keyboard/Return
CycleAspectRatio = Keyboard/F6
CycleInterlaceMode = Keyboard/F5
CycleMipmapMode = Keyboard/Insert
GSDumpMultiFrame = Keyboard/Control & Keyboard/Shift & Keyboard/F8
Screenshot = Keyboard/F8
GSDumpSingleFrame = Keyboard/Shift & Keyboard/F8
ToggleSoftwareRendering = Keyboard/F9
ZoomIn = Keyboard/Control & Keyboard/Plus
ZoomOut = Keyboard/Control & Keyboard/Minus
InputRecToggleMode = Keyboard/Shift & Keyboard/R
LoadStateFromSlot = Keyboard/F3
SaveStateToSlot = Keyboard/F1
NextSaveStateSlot = Keyboard/F2
PreviousSaveStateSlot = Keyboard/Shift & Keyboard/F2
OpenPauseMenu = Keyboard/Escape
OpenPauseMenu = SDL-0/Back & SDL-0/Start
OpenPauseMenu = SDL-1/Back & SDL-1/Start
OpenPauseMenu = SDL-2/Back & SDL-2/Start
OpenPauseMenu = SDL-3/Back & SDL-3/Start
OpenPauseMenu = SDL-4/Back & SDL-4/Start
OpenPauseMenu = SDL-5/Back & SDL-5/Start
OpenPauseMenu = SDL-6/Back & SDL-6/Start
OpenPauseMenu = SDL-7/Back & SDL-7/Start
ToggleFrameLimit = Keyboard/F4
TogglePause = Keyboard/Space
ToggleSlowMotion = Keyboard/Shift & Keyboard/Backtab
ToggleTurbo = Keyboard/Tab
HoldTurbo = Keyboard/Period


[Pad]
MultitapPort1 = false
MultitapPort2 = false
PointerXScale = 8
PointerYScale = 8


[Pad1]
Type = DualShock2
InvertL = 0
InvertR = 0
Deadzone = 0
AxisScale = 1.33
LargeMotorScale = 1
SmallMotorScale = 1
ButtonDeadzone = 0
PressureModifier = 0.5
Up = SDL-0/DPadUp
Right = SDL-0/DPadRight
Down = SDL-0/DPadDown
Left = SDL-0/DPadLeft
Triangle = SDL-0/Y
Circle = SDL-0/B
Cross = SDL-0/A
Square = SDL-0/X
Select = SDL-0/Back
Start = SDL-0/Start
L1 = SDL-0/LeftShoulder
L2 = SDL-0/+LeftTrigger
R1 = SDL-0/RightShoulder
R2 = SDL-0/+RightTrigger
L3 = SDL-0/LeftStick
R3 = SDL-0/RightStick
LUp = SDL-0/-LeftY
LRight = SDL-0/+LeftX
LDown = SDL-0/+LeftY
LLeft = SDL-0/-LeftX
RUp = SDL-0/-RightY
RRight = SDL-0/+RightX
RDown = SDL-0/+RightY
RLeft = SDL-0/-RightX
Analog = SDL-0/Guide
LargeMotor = SDL-0/LargeMotor
SmallMotor = SDL-0/SmallMotor


[Pad2]
Type = None


[Pad3]
Type = None


[Pad4]
Type = None


[Pad5]
Type = None


[Pad6]
Type = None


[Pad7]
Type = None


[Pad8]
Type = None


_EOF_
    fi

    chown $__user:$__group -R "$md_conf_root/ps2/Config"

}