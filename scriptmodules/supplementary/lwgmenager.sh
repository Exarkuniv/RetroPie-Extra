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

rp_module_id="lwgmenager"
rp_module_desc="RetroPie Light Web Game Manager - Flask web panel to manage files and monitor your Pi"
rp_module_help="Open http://<your-pi-ip>:5000 in a browser (default login: admin / password: admin).\n\nManage your RetroPie files, monitor system stats and reboot/shutdown from the web interface.\nRun 'sudo $md_inst/gui_web_panel.sh' over SSH for a text based configuration menu."
rp_module_licence="https://github.com/woojak/retropie_lwgmenager"
rp_module_repo="git https://github.com/woojak/retropie_lwgmenager.git main"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_lwgmenager() {
    local depends=(git python3 python3-flask python3-psutil whiptail)
    getDepends "${depends[@]}"
}

function sources_lwgmenager() {
    gitPullOrClone
}

function install_lwgmenager() {
    md_ret_files=(
        'web_panel.py'
        'config.cfg'
        'gui_web_panel.sh'
        'uninstall.sh'
        'web_panel.service'
        'README.md'
        'images'
    )
}

function _service_lwgmenager() {
    echo "${md_id}_web_panel.service"
}

function _ip_lwgmenager() {
    local ip
    if fnExists getIPAddress; then
        ip="$(getIPAddress)"
    fi
    [[ -z "$ip" ]] && ip="$(hostname -I 2>/dev/null | awk '{print $1}')"
    echo "$ip"
}

function remove_lwgmenager() {
    local service="$(_service_lwgmenager)"
    systemctl stop "$service" 2>/dev/null
    systemctl disable "$service" 2>/dev/null
    rm -f "/etc/systemd/system/$service"
    systemctl daemon-reload
}

function configure_lwgmenager() {
    local service="$(_service_lwgmenager)"

    if [[ "$md_mode" == "remove" ]]; then
        remove_lwgmenager
        return
    fi

    local tmp_dir="$home/tmp"
    mkUserDir "$tmp_dir"
    chmod 1777 "$tmp_dir"

    sed -i "s|TEMP_DIR = '/home/pi/tmp'|TEMP_DIR = '$tmp_dir'|" "$md_inst/web_panel.py"
    sed -i "s|BASE_DIR = os.path.abspath(\"/home/pi/RetroPie\")|BASE_DIR = os.path.abspath(\"$datadir\")|" "$md_inst/web_panel.py"

    local config_location="32"
    [[ -f /boot/firmware/config.txt ]] && config_location="64"

    iniConfig "=" "" "$md_inst/config.cfg"
    iniSet "login" "admin"
    iniSet "password" "admin"
    iniSet "secret_key" "your_secret_key"
    iniSet "port" "5000"
    iniSet "monitor_refresh" "1.1"
    iniSet "config_location" "$config_location"

    chown -R "$user:$user" "$md_inst"

    cat > "/etc/systemd/system/$service" << _EOF_
[Unit]
Description=RetroPie Light Web Game Manager
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=$md_inst
ExecStart=/usr/bin/python3 $md_inst/web_panel.py
Environment=TMPDIR=$tmp_dir
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
_EOF_

    systemctl daemon-reload
    systemctl enable "$service"
    systemctl restart "$service"

    local ip
    ip="$(_ip_lwgmenager)"
    printMsgs "console" "The RetroPie Light Web Game Manager service is running.\n\nOpen http://${ip:-<your-pi-ip>}:5000 in a browser.\nDefault login: admin  /  password: admin"
}

function gui_lwgmenager() {
    local service="$(_service_lwgmenager)"
    local ip
    while true; do
        local status="stopped"
        systemctl is-active --quiet "$service" && status="running"
        ip="$(_ip_lwgmenager)"

        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Back" --menu "RetroPie Light Web Game Manager (service: $status)\nURL: http://${ip:-<your-pi-ip>}:5000" 22 76 16)
        local options=(
            1 "Start service"
            2 "Stop service"
            3 "Restart service"
            4 "Enable service (start on boot)"
            5 "Disable service (do not start on boot)"
            6 "Show service status / logs"
        )
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        case "$choice" in
            1)
                systemctl start "$service"
                printMsgs "dialog" "Service started."
                ;;
            2)
                systemctl stop "$service"
                printMsgs "dialog" "Service stopped."
                ;;
            3)
                systemctl restart "$service"
                printMsgs "dialog" "Service restarted."
                ;;
            4)
                systemctl enable "$service"
                printMsgs "dialog" "Service enabled to start on boot."
                ;;
            5)
                systemctl disable "$service"
                printMsgs "dialog" "Service disabled from starting on boot."
                ;;
            6)
                printMsgs "dialog" "$(systemctl status "$service" 2>&1 | head -n 20)"
                ;;
        esac
    done
}
