#!/bin/zsh
# =============================================================================
# MihomoMacCLI - Mihomo Service Manager
# An all-in-one TUI for managing mihomo on macOS
# https://github.com/livingfree2023/MihomoMacCLI
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
MIHOMO_BIN="/usr/local/bin/mihomo"
MIHOMO_CONFIG_DIR="$HOME/.config/mihomo"
MIHOMO_CONFIGS_DIR="$MIHOMO_CONFIG_DIR/configs"
MIHOMO_CONFIG="$MIHOMO_CONFIG_DIR/config.yaml"
MIHOMO_SERVICE_SCRIPT="$MIHOMO_CONFIG_DIR/mihomo-service.sh"
MIHOMO_PLIST="$HOME/Library/LaunchAgents/com.mihomo.service.plist"
MIHOMO_LOG="$MIHOMO_CONFIG_DIR/service.log"
MIHOMO_ERR="$MIHOMO_CONFIG_DIR/service.err"
MIHOMO_INTERFACE="Wi-Fi"
GITHUB_API="https://api.github.com/repos/MetaCubeX/mihomo/releases/latest"
MIHOMO_LANG_FILE="$MIHOMO_CONFIG_DIR/.lang"

# ---------------------------------------------------------------------------
# i18n Strings
# ---------------------------------------------------------------------------
typeset -A STR_EN
typeset -A STR_ZH

# General
STR_EN[app_title]="Mihomo Service Manager"
STR_ZH[app_title]="Mihomo 服务管理器"
STR_EN[current_status]="Current Status"
STR_ZH[current_status]="当前状态"
STR_EN[goodbye]="Goodbye!"
STR_ZH[goodbye]="再见！"
STR_EN[invalid_option]="Invalid option"
STR_ZH[invalid_option]="无效选项"
STR_EN[press_enter]="Press Enter to continue..."
STR_ZH[press_enter]="按回车键继续..."
STR_EN[menu_prompt]="Choose an option [0-8]"
STR_ZH[menu_prompt]="请选择 [0-8]"

# Menu items
STR_EN[menu_install]="Install Mihomo"
STR_ZH[menu_install]="安装 Mihomo"
STR_EN[menu_install_desc]="Download latest binary from GitHub"
STR_ZH[menu_install_desc]="从 GitHub 下载最新版本"
STR_EN[menu_import]="Import Subscription"
STR_ZH[menu_import]="导入订阅"
STR_EN[menu_import_desc]="Enter URL or path to .yaml file"
STR_ZH[menu_import_desc]="输入 URL 或 .yaml 文件路径"
STR_EN[menu_select]="Select Config"
STR_ZH[menu_select]="选择配置"
STR_EN[menu_select_desc]="Switch between imported configs"
STR_ZH[menu_select_desc]="在已导入的配置间切换"
STR_EN[menu_start]="Start Service"
STR_ZH[menu_start]="启动服务"
STR_EN[menu_start_desc]="Install and run as launchd service"
STR_ZH[menu_start_desc]="安装并运行 launchd 服务"
STR_EN[menu_stop]="Stop Service"
STR_ZH[menu_stop]="停止服务"
STR_EN[menu_stop_desc]="Stop the running service"
STR_ZH[menu_stop_desc]="停止运行中的服务"
STR_EN[menu_panel]="Open MetaCubeXD Panel"
STR_ZH[menu_panel]="打开 MetaCubeXD 面板"
STR_EN[menu_panel_desc]="Open web dashboard in browser"
STR_ZH[menu_panel_desc]="在浏览器中打开 Web 面板"
STR_EN[menu_uninstall]="Uninstall"
STR_ZH[menu_uninstall]="卸载"
STR_EN[menu_uninstall_desc]="Remove service, binary, and config"
STR_ZH[menu_uninstall_desc]="移除服务、程序和配置"
STR_EN[menu_language]="Language / 语言"
STR_ZH[menu_language]="Language / 语言"
STR_EN[menu_language_desc]="Switch display language"
STR_ZH[menu_language_desc]="切换显示语言"
STR_EN[menu_exit]="Exit"
STR_ZH[menu_exit]="退出"

# Status
STR_EN[binary_installed]="Binary installed: %s"
STR_ZH[binary_installed]="已安装: %s"
STR_EN[binary_not_installed]="Binary not installed"
STR_ZH[binary_not_installed]="未安装"
STR_EN[active_config]="Active config: %s.yaml (port: %s)"
STR_ZH[active_config]="当前配置: %s.yaml (端口: %s)"
STR_EN[total_configs]="Total configs: %s"
STR_ZH[total_configs]="配置总数: %s"
STR_EN[no_config_file]="No config file"
STR_ZH[no_config_file]="无配置文件"
STR_EN[service_running]="Service running"
STR_ZH[service_running]="服务运行中"
STR_EN[service_not_running]="Service not running"
STR_ZH[service_not_running]="服务未运行"
STR_EN[port_label]="port"
STR_ZH[port_label]="端口"
STR_EN[active_label]="active"
STR_ZH[active_label]="当前"

# Install
STR_EN[install_header]="── Install Mihomo ──"
STR_ZH[install_header]="── 安装 Mihomo ──"
STR_EN[unsupported_arch]="Unsupported architecture: %s"
STR_ZH[unsupported_arch]="不支持的架构: %s"
STR_EN[detected_arch]="Detected architecture: %s (%s)"
STR_ZH[detected_arch]="检测到架构: %s (%s)"
STR_EN[fetching_release]="Fetching latest release info..."
STR_ZH[fetching_release]="获取最新版本信息..."
STR_EN[fetch_failed]="Failed to fetch release info. Check your network."
STR_ZH[fetch_failed]="获取版本信息失败，请检查网络。"
STR_EN[parse_failed]="Failed to parse release info"
STR_ZH[parse_failed]="解析版本信息失败"
STR_EN[latest_version]="Latest version: %s"
STR_ZH[latest_version]="最新版本: %s"
STR_EN[asset_not_found]="Could not find download for darwin/%s"
STR_ZH[asset_not_found]="找不到 darwin/%s 的下载文件"
STR_EN[check_releases]="Please check: https://github.com/MetaCubeX/mihomo/releases/latest"
STR_ZH[check_releases]="请检查: https://github.com/MetaCubeX/mihomo/releases/latest"
STR_EN[downloading]="Downloading: %s"
STR_ZH[downloading]="下载中: %s"
STR_EN[download_failed]="Download failed"
STR_ZH[download_failed]="下载失败"
STR_EN[creating_dir]="Creating directory: %s"
STR_ZH[creating_dir]="创建目录: %s"
STR_EN[installing_to]="Installing to: %s"
STR_ZH[installing_to]="安装到: %s"
STR_EN[install_success]="Mihomo installed successfully!"
STR_ZH[install_success]="Mihomo 安装成功！"

# Import
STR_EN[import_header]="── Import Subscription ──"
STR_ZH[import_header]="── 导入订阅 ──"
STR_EN[binary_not_installed_first]="Mihomo binary not installed. Install it first (Option 1)."
STR_ZH[binary_not_installed_first]="Mihomo 未安装，请先安装（选项 1）。"
STR_EN[subscription_prompt]="Enter subscription URL or path to .yaml file"
STR_ZH[subscription_prompt]="请输入订阅链接或 .yaml 文件路径"
STR_EN[config_name_prompt]="Enter a name for this config (e.g. 'home', 'airport')"
STR_ZH[config_name_prompt]="为此配置命名（如 'home', 'airport'）"
STR_EN[empty_input]="Empty input"
STR_ZH[empty_input]="输入为空"
STR_EN[copying_local]="Copying local config: %s"
STR_ZH[copying_local]="复制本地配置: %s"
STR_EN[import_local_success]="Config imported from local file"
STR_ZH[import_local_success]="已从本地文件导入配置"
STR_EN[downloading_sub]="Downloading subscription..."
STR_ZH[downloading_sub]="下载订阅..."
STR_EN[import_url_success]="Subscription imported from URL"
STR_ZH[import_url_success]="已从 URL 导入订阅"
STR_EN[download_sub_failed]="Failed to download subscription"
STR_ZH[download_sub_failed]="下载订阅失败"
STR_EN[invalid_input]="Invalid input. Provide a URL or file path."
STR_ZH[invalid_input]="无效输入，请提供 URL 或文件路径。"
STR_EN[validating_config]="Validating config..."
STR_ZH[validating_config]="验证配置..."
STR_EN[config_valid]="Config is valid"
STR_ZH[config_valid]="配置有效"
STR_EN[config_warning]="Config validation returned warnings. Check the file."
STR_ZH[config_warning]="配置验证有警告，请检查文件。"
STR_EN[set_active_config]="Set as active config: %s.yaml"
STR_ZH[set_active_config]="已设为当前配置: %s.yaml"
STR_EN[detected_port]="Detected proxy port: %s"
STR_ZH[detected_port]="检测到代理端口: %s"

# Select Config
STR_EN[select_header]="── Select Config ──"
STR_ZH[select_header]="── 选择配置 ──"
STR_EN[no_configs_dir]="No configs directory. Import a subscription first (Option 2)."
STR_ZH[no_configs_dir]="无配置目录，请先导入订阅（选项 2）。"
STR_EN[no_config_files]="No config files found. Import a subscription first (Option 2)."
STR_ZH[no_config_files]="未找到配置文件，请先导入订阅（选项 2）。"
STR_EN[select_config_prompt]="Select config number (or Enter to cancel)"
STR_ZH[select_config_prompt]="选择配置编号（回车取消）"
STR_EN[cancelled]="Cancelled"
STR_ZH[cancelled]="已取消"
STR_EN[invalid_selection]="Invalid selection"
STR_ZH[invalid_selection]="无效选择"
STR_EN[switched_to]="Switched to: %s.yaml (port: %s)"
STR_ZH[switched_to]="已切换到: %s.yaml（端口: %s）"
STR_EN[restart_to_apply]="Service is running. Restart it (Option 4) to apply the new config."
STR_ZH[restart_to_apply]="服务正在运行，请重启服务（选项 4）以应用新配置。"

# Service
STR_EN[service_header]="── Install & Start Service ──"
STR_ZH[service_header]="── 安装并启动服务 ──"
STR_EN[no_config_service]="No config file found. Import a subscription first (Option 2)."
STR_ZH[no_config_service]="无配置文件，请先导入订阅（选项 2）。"
STR_EN[stopping_existing]="Stopping existing service..."
STR_ZH[stopping_existing]="停止现有服务..."
STR_EN[generating_files]="Generating service files..."
STR_ZH[generating_files]="生成服务文件..."
STR_EN[loading_service]="Loading service..."
STR_ZH[loading_service]="加载服务..."
STR_EN[service_started]="Service installed and started!"
STR_ZH[service_started]="服务已安装并启动！"
STR_EN[system_proxy_set]="System proxy set on %s:%s"
STR_ZH[system_proxy_set]="系统代理已设置在 %s:%s"
STR_EN[logs_location]="Logs: %s"
STR_ZH[logs_location]="日志: %s"
STR_EN[service_failed]="Service failed to start. Check logs: %s"
STR_ZH[service_failed]="服务启动失败，请检查日志: %s"

# Stop
STR_EN[stop_header]="── Stop Service ──"
STR_ZH[stop_header]="── 停止服务 ──"
STR_EN[service_not_running_stop]="Service is not running"
STR_ZH[service_not_running_stop]="服务未运行"
STR_EN[stopping_service]="Stopping service..."
STR_ZH[stopping_service]="停止服务..."
STR_EN[restoring_proxy]="Restoring proxy settings..."
STR_ZH[restoring_proxy]="恢复代理设置..."
STR_EN[service_stopped]="Service stopped"
STR_ZH[service_stopped]="服务已停止"
STR_EN[stop_failed]="Failed to stop service"
STR_ZH[stop_failed]="停止服务失败"

# Panel
STR_EN[panel_header]="── Open MetaCubeXD Panel ──"
STR_ZH[panel_header]="── 打开 MetaCubeXD 面板 ──"
STR_EN[opening_panel]="Opening MetaCubeXD panel in default browser..."
STR_ZH[opening_panel]="在默认浏览器中打开 MetaCubeXD 面板..."
STR_EN[panel_opened]="Panel opened"
STR_ZH[panel_opened]="面板已打开"

# Uninstall
STR_EN[uninstall_header]="── Uninstall Mihomo ──"
STR_ZH[uninstall_header]="── 卸载 Mihomo ──"
STR_EN[uninstall_confirm]="This will remove mihomo service, binary, and config. Continue?"
STR_ZH[uninstall_confirm]="这将移除 mihomo 服务、程序和配置。继续？"
STR_EN[uninstall_cancelled]="Cancelled"
STR_ZH[uninstall_cancelled]="已取消"
STR_EN[stopping_service_uninstall]="Stopping service..."
STR_ZH[stopping_service_uninstall]="停止服务..."
STR_EN[restoring_proxy_uninstall]="Restoring proxy settings..."
STR_ZH[restoring_proxy_uninstall]="恢复代理设置..."
STR_EN[removed_plist]="Removed plist"
STR_ZH[removed_plist]="已移除 plist"
STR_EN[removed_service_script]="Removed service script"
STR_ZH[removed_service_script]="已移除服务脚本"
STR_EN[remove_config_confirm]="Remove config directory too?"
STR_ZH[remove_config_confirm]="同时删除配置目录？"
STR_EN[removed_config_dir]="Removed config directory"
STR_ZH[removed_config_dir]="已移除配置目录"
STR_EN[removed_binary]="Removed binary: %s"
STR_ZH[removed_binary]="已移除程序: %s"
STR_EN[uninstall_success]="Mihomo has been fully uninstalled"
STR_ZH[uninstall_success]="Mihomo 已完全卸载"

# Language
STR_EN[language_header]="── Language ──"
STR_ZH[language_header]="── 语言 ──"
STR_EN[language_prompt]="Select language [1] English [2] 中文"
STR_ZH[language_prompt]="选择语言 [1] English [2] 中文"
STR_EN[language_set]="Language set to English"
STR_ZH[language_set]="语言已设置为中文"

# ---------------------------------------------------------------------------
# i18n Lookup
# ---------------------------------------------------------------------------
_() {
    local key="$1"
    shift
    local str
    if [[ "$LANGUAGE" == "zh" ]]; then
        str="${STR_ZH[$key]}"
    else
        str="${STR_EN[$key]}"
    fi
    # Support printf-style arguments
    if (( $# > 0 )); then
        printf "$str" "$@"
    else
        print -- "$str"
    fi
}

# ---------------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ---------------------------------------------------------------------------
# Helper Functions
# ---------------------------------------------------------------------------

info()    { print "${BLUE}[INFO]${NC} $1" }
success() { print "${GREEN}[OK]${NC} $1" }
warn()    { print "${YELLOW}[WARN]${NC} $1" }
error()   { print "${RED}[ERROR]${NC} $1" }

confirm() {
    local prompt="$1"
    local reply
    print -n "${CYAN}${prompt} [y/N]: ${NC}"
    read -r reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

press_enter() {
    print ""
    print -n "${CYAN}$(_ press_enter)${NC}"
    read -r
}

# ---------------------------------------------------------------------------
# Language Selection
# ---------------------------------------------------------------------------

select_language() {
    print ""
    print "${BOLD}$(_ language_header)${NC}"
    print ""
    print "  ${BOLD}[1]${NC} English"
    print "  ${BOLD}[2]${NC} 中文 (Chinese)"
    print ""
    print -n "${CYAN}$(_ language_prompt): ${NC}"
    local choice
    read -r choice

    case "$choice" in
        1) LANGUAGE="en" ;;
        2) LANGUAGE="zh" ;;
        *) info "$(_ cancelled)"; return 0 ;;
    esac

    mkdir -p "$MIHOMO_CONFIG_DIR"
    print "$LANGUAGE" > "$MIHOMO_LANG_FILE"
    success "$(_ language_set)"
}

# Load language preference
LANGUAGE="en"
if [[ -f "$MIHOMO_LANG_FILE" ]]; then
    LANGUAGE=$(tr -d '[:space:]' < "$MIHOMO_LANG_FILE")
    [[ "$LANGUAGE" != "zh" ]] && LANGUAGE="en"
fi

# ---------------------------------------------------------------------------
# Port Extraction
# ---------------------------------------------------------------------------

extract_port() {
    local config_file="${1:-$MIHOMO_CONFIG}"
    if [[ ! -f "$config_file" ]]; then
        echo ""
        return 1
    fi

    # Try mixed-port first, then port, then default to 7890
    local port
    port=$(grep -E '^\s*mixed-port:\s*' "$config_file" | head -1 | awk '{print $2}' 2>/dev/null)
    if [[ -z "$port" ]]; then
        port=$(grep -E '^\s*port:\s*' "$config_file" | head -1 | awk '{print $2}' 2>/dev/null)
    fi
    if [[ -z "$port" ]]; then
        port=7890
    fi
    echo "$port"
}

get_active_config_name() {
    if [[ -L "$MIHOMO_CONFIG" ]]; then
        local target
        target=$(readlink "$MIHOMO_CONFIG")
        basename "$target" .yaml
    elif [[ -f "$MIHOMO_CONFIG" ]]; then
        echo "config"
    else
        echo ""
    fi
}

# ---------------------------------------------------------------------------
# Status Check
# ---------------------------------------------------------------------------

is_service_running() {
    launchctl print gui/$(id -u)/com.mihomo.service &>/dev/null
}

is_binary_installed() {
    [[ -x "$MIHOMO_BIN" ]]
}

is_config_exists() {
    [[ -f "$MIHOMO_CONFIG" ]]
}

show_status() {
    print ""
    print "${BOLD}═══════════════════════════════════════════════════${NC}"
    print "${BOLD}  $(_ current_status)${NC}"
    print "${BOLD}═══════════════════════════════════════════════════${NC}"

    if is_binary_installed; then
        local ver
        ver=$("$MIHOMO_BIN" -v 2>/dev/null | head -1 || echo "unknown")
        success "$(_ binary_installed "$ver")"
    else
        warn "$(_ binary_not_installed)"
    fi

    if is_config_exists; then
        local active_name
        active_name=$(get_active_config_name)
        local port
        port=$(extract_port "$MIHOMO_CONFIG")
        success "$(_ active_config "$active_name" "$port")"

        local config_count=0
        if [[ -d "$MIHOMO_CONFIGS_DIR" ]]; then
            config_count=$(find "$MIHOMO_CONFIGS_DIR" -name '*.yaml' -maxdepth 1 2>/dev/null | wc -l | tr -d ' ')
        fi
        info "$(_ total_configs "$config_count")"
    else
        warn "$(_ no_config_file)"
    fi

    if is_service_running; then
        success "$(_ service_running)"
    else
        warn "$(_ service_not_running)"
    fi

    print "${BOLD}═══════════════════════════════════════════════════${NC}"
}

# ---------------------------------------------------------------------------
# 1. Install Mihomo
# ---------------------------------------------------------------------------

install_mihomo() {
    print ""
    print "${BOLD}$(_ install_header)${NC}"
    print ""

    # Detect architecture
    local arch_raw
    arch_raw=$(uname -m)
    local arch
    case "$arch_raw" in
        arm64)  arch="arm64" ;;
        x86_64) arch="amd64" ;;
        *)
            error "$(_ unsupported_arch "$arch_raw")"
            return 1
            ;;
    esac
    info "$(_ detected_arch "$arch" "$arch_raw")"

    # Fetch latest release info from GitHub
    info "$(_ fetching_release)"
    local release_json
    release_json=$(curl -fsSL "$GITHUB_API" 2>/dev/null) || {
        error "$(_ fetch_failed)"
        return 1
    }

    # Extract version tag
    local tag
    tag=$(echo "$release_json" | python3 -c "import sys,json; print(json.load(sys.stdin)['tag_name'])" 2>/dev/null) || {
        error "$(_ parse_failed)"
        return 1
    }
    info "$(_ latest_version "$tag")"

    # Find the correct asset
    local asset_name="mihomo-darwin-${arch}-${tag}.gz"
    local download_url
    download_url=$(echo "$release_json" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for asset in data.get('assets', []):
    if '${asset_name}' in asset['name']:
        print(asset['browser_download_url'])
        break
" 2>/dev/null)

    if [[ -z "$download_url" ]]; then
        # Try without version prefix in asset name
        asset_name="mihomo-darwin-${arch}.gz"
        download_url=$(echo "$release_json" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for asset in data.get('assets', []):
    name = asset['name']
    if 'darwin' in name and '${arch}' in name and name.endswith('.gz') and 'compatible' not in name:
        print(asset['browser_download_url'])
        break
" 2>/dev/null)
    fi

    if [[ -z "$download_url" ]]; then
        error "$(_ asset_not_found "$arch")"
        error "$(_ check_releases)"
        return 1
    fi

    info "$(_ downloading "$download_url")"

    # Download to temp file
    local tmp_file
    tmp_file=$(mktemp /tmp/mihomo-XXXXXX.gz)
    if ! curl -fSL --progress-bar -o "$tmp_file" "$download_url"; then
        error "$(_ download_failed)"
        rm -f "$tmp_file"
        return 1
    fi

    # Ensure target directory exists
    if [[ ! -d "$(dirname "$MIHOMO_BIN")" ]]; then
        info "$(_ creating_dir "$(dirname "$MIHOMO_BIN")")"
        sudo mkdir -p "$(dirname "$MIHOMO_BIN")"
    fi

    # Decompress and install
    info "$(_ installing_to "$MIHOMO_BIN")"
    gunzip -f "$tmp_file"
    local raw_bin="${tmp_file%.gz}"

    # Need sudo for /usr/local/bin
    if [[ -w "$(dirname "$MIHOMO_BIN")" ]]; then
        mv "$raw_bin" "$MIHOMO_BIN"
    else
        sudo mv "$raw_bin" "$MIHOMO_BIN"
    fi
    chmod +x "$MIHOMO_BIN"

    success "$(_ install_success)"
    "$MIHOMO_BIN" -v 2>/dev/null | head -1 || true
}

# ---------------------------------------------------------------------------
# 2. Import Subscription
# ---------------------------------------------------------------------------

import_subscription() {
    print ""
    print "${BOLD}$(_ import_header)${NC}"
    print ""

    if ! is_binary_installed; then
        warn "$(_ binary_not_installed_first)"
        return 1
    fi

    print "$(_ subscription_prompt)"
    print -n "${CYAN}> ${NC}"
    local input
    read -r input

    input="${input#[\"\']}"
    input="${input%[\"\']}"

    if [[ -z "$input" ]]; then
        error "$(_ empty_input)"
        return 1
    fi

    print ""
    print "$(_ config_name_prompt)"
    print -n "${CYAN}> ${NC}"
    local config_name
    read -r config_name

    config_name="${config_name#[\"\']}"
    config_name="${config_name%[\"\']}"

    if [[ -z "$config_name" ]]; then
        config_name="default"
    fi
    config_name="${config_name%.yaml}"

    mkdir -p "$MIHOMO_CONFIGS_DIR"

    local target_file="$MIHOMO_CONFIGS_DIR/${config_name}.yaml"

    if [[ -f "$input" ]]; then
        info "$(_ copying_local "$input")"
        cp "$input" "$target_file"
        success "$(_ import_local_success)"

    elif [[ "$input" =~ ^https?:// ]]; then
        info "$(_ downloading_sub)"
        if curl -fSL --progress-bar -o "$target_file" "$input"; then
            success "$(_ import_url_success)"
        else
            error "$(_ download_sub_failed)"
            rm -f "$target_file"
            return 1
        fi
    else
        error "$(_ invalid_input)"
        return 1
    fi

    if [[ -f "$target_file" ]]; then
        info "$(_ validating_config)"
        if "$MIHOMO_BIN" -t -f "$target_file" &>/dev/null; then
            success "$(_ config_valid)"
        else
            warn "$(_ config_warning)"
        fi

        ln -sf "$target_file" "$MIHOMO_CONFIG"
        success "$(_ set_active_config "$config_name")"

        local port
        port=$(extract_port "$target_file")
        info "$(_ detected_port "$port")"
    fi
}

# ---------------------------------------------------------------------------
# 3. Select Config
# ---------------------------------------------------------------------------

select_config() {
    print ""
    print "${BOLD}$(_ select_header)${NC}"
    print ""

    if [[ ! -d "$MIHOMO_CONFIGS_DIR" ]]; then
        warn "$(_ no_configs_dir)"
        return 1
    fi

    local configs=()
    local i=1
    local active_name
    active_name=$(get_active_config_name)

    for f in "$MIHOMO_CONFIGS_DIR"/*.yaml(N); do
        local name
        name=$(basename "$f" .yaml)
        local port
        port=$(extract_port "$f")
        if [[ "$name" == "$active_name" ]]; then
            configs+=("$f")
            print "  ${GREEN}[${i}]${NC} ${BOLD}${name}.yaml${NC} ($(_ port_label): ${port}) ${GREEN}← $(_ active_label)${NC}"
        else
            configs+=("$f")
            print "  ${BOLD}[${i}]${NC} ${name}.yaml ($(_ port_label): ${port})"
        fi
        ((i++))
    done

    if [[ ${#configs[@]} -eq 0 ]]; then
        warn "$(_ no_config_files)"
        return 1
    fi

    print ""
    print -n "${CYAN}$(_ select_config_prompt): ${NC}"
    local choice
    read -r choice

    if [[ -z "$choice" ]]; then
        info "$(_ cancelled)"
        return 0
    fi

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#configs[@]} )); then
        error "$(_ invalid_selection)"
        return 1
    fi

    local selected="${configs[$choice]}"
    local selected_name
    selected_name=$(basename "$selected" .yaml)

    ln -sf "$selected" "$MIHOMO_CONFIG"
    local port
    port=$(extract_port "$selected")
    success "$(_ switched_to "$selected_name" "$port")"

    if is_service_running; then
        warn "$(_ restart_to_apply)"
    fi
}

# ---------------------------------------------------------------------------
# 4. Install & Start Service
# ---------------------------------------------------------------------------

generate_service_script() {
    local port
    port=$(extract_port "$MIHOMO_CONFIG")

    cat > "$MIHOMO_SERVICE_SCRIPT" << 'SCRIPT_EOF'
#!/bin/zsh
# Mihomo service wrapper - auto-generated by mihomo-manager

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"

MIHOMO_BIN="__MIHOMO_BIN__"
MIHOMO_CONFIG="__MIHOMO_CONFIG__"
MIHOMO_PORT=__MIHOMO_PORT__
MIHOMO_INTERFACE="__MIHOMO_INTERFACE__"

cleanup() {
    networksetup -setwebproxystate "$MIHOMO_INTERFACE" off 2>/dev/null
    networksetup -setsecurewebproxystate "$MIHOMO_INTERFACE" off 2>/dev/null
    networksetup -setsocksfirewallproxystate "$MIHOMO_INTERFACE" off 2>/dev/null
    exit 0
}

trap cleanup TERM INT HUP

networksetup -setwebproxy "$MIHOMO_INTERFACE" 127.0.0.1 "$MIHOMO_PORT"
networksetup -setsecurewebproxy "$MIHOMO_INTERFACE" 127.0.0.1 "$MIHOMO_PORT"
networksetup -setsocksfirewallproxy "$MIHOMO_INTERFACE" 127.0.0.1 "$MIHOMO_PORT"

exec "$MIHOMO_BIN" -f "$MIHOMO_CONFIG"
SCRIPT_EOF

    sed -i '' "s|__MIHOMO_BIN__|${MIHOMO_BIN}|g" "$MIHOMO_SERVICE_SCRIPT"
    sed -i '' "s|__MIHOMO_CONFIG__|${MIHOMO_CONFIG}|g" "$MIHOMO_SERVICE_SCRIPT"
    sed -i '' "s|__MIHOMO_PORT__|${port}|g" "$MIHOMO_SERVICE_SCRIPT"
    sed -i '' "s|__MIHOMO_INTERFACE__|${MIHOMO_INTERFACE}|g" "$MIHOMO_SERVICE_SCRIPT"
    chmod +x "$MIHOMO_SERVICE_SCRIPT"
}

generate_plist() {
    cat > "$MIHOMO_PLIST" << PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.mihomo.service</string>
    <key>ProgramArguments</key>
    <array>
        <string>${MIHOMO_SERVICE_SCRIPT}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>${MIHOMO_LOG}</string>
    <key>StandardErrorPath</key>
    <string>${MIHOMO_ERR}</string>
</dict>
</plist>
PLIST_EOF
}

install_service() {
    print ""
    print "${BOLD}$(_ service_header)${NC}"
    print ""

    # Pre-checks
    if ! is_binary_installed; then
        error "$(_ binary_not_installed_first)"
        return 1
    fi

    if ! is_config_exists; then
        error "$(_ no_config_service)"
        return 1
    fi

    # Stop existing service if running
    if is_service_running; then
        info "$(_ stopping_existing)"
        launchctl bootout gui/$(id -u) "$MIHOMO_PLIST" 2>/dev/null || true
        sleep 1
    fi

    # Ensure directories exist
    mkdir -p "$MIHOMO_CONFIG_DIR"
    mkdir -p "$HOME/Library/LaunchAgents"

    # Generate service script and plist
    info "$(_ generating_files)"
    generate_service_script
    generate_plist

    # Load the service
    info "$(_ loading_service)"
    launchctl bootstrap gui/$(id -u) "$MIHOMO_PLIST"

    sleep 2

    if is_service_running; then
        local port
        port=$(extract_port "$MIHOMO_CONFIG")
        success "$(_ service_started)"
        info "$(_ system_proxy_set "$MIHOMO_INTERFACE" "$port")"
        info "$(_ logs_location "$MIHOMO_LOG")"
    else
        error "$(_ service_failed "$MIHOMO_ERR")"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# 5. Stop Service
# ---------------------------------------------------------------------------

stop_service() {
    print ""
    print "${BOLD}$(_ stop_header)${NC}"
    print ""

    if ! is_service_running; then
        warn "$(_ service_not_running_stop)"
        return 0
    fi

    info "$(_ stopping_service)"
    launchctl bootout gui/$(id -u) "$MIHOMO_PLIST" 2>/dev/null || true

    # Restore proxy settings
    info "$(_ restoring_proxy)"
    networksetup -setwebproxystate "$MIHOMO_INTERFACE" off 2>/dev/null || true
    networksetup -setsecurewebproxystate "$MIHOMO_INTERFACE" off 2>/dev/null || true
    networksetup -setsocksfirewallproxystate "$MIHOMO_INTERFACE" off 2>/dev/null || true

    sleep 1

    if ! is_service_running; then
        success "$(_ service_stopped)"
    else
        error "$(_ stop_failed)"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# 6. Open MetaCubeXD Panel
# ---------------------------------------------------------------------------

open_panel() {
    print ""
    print "${BOLD}$(_ panel_header)${NC}"
    print ""

    info "$(_ opening_panel)"
    open "https://metacubex.github.io/metacubexd/"
    success "$(_ panel_opened)"
}

# ---------------------------------------------------------------------------
# 7. Uninstall
# ---------------------------------------------------------------------------

uninstall_all() {
    print ""
    print "${BOLD}$(_ uninstall_header)${NC}"
    print ""

    if ! confirm "$(_ uninstall_confirm)"; then
        info "$(_ uninstall_cancelled)"
        return 0
    fi

    # Stop and remove service
    if is_service_running; then
        info "$(_ stopping_service_uninstall)"
        launchctl bootout gui/$(id -u) "$MIHOMO_PLIST" 2>/dev/null || true
        sleep 1
    fi

    # Restore proxy
    info "$(_ restoring_proxy_uninstall)"
    networksetup -setwebproxystate "$MIHOMO_INTERFACE" off 2>/dev/null || true
    networksetup -setsecurewebproxystate "$MIHOMO_INTERFACE" off 2>/dev/null || true
    networksetup -setsocksfirewallproxystate "$MIHOMO_INTERFACE" off 2>/dev/null || true

    # Remove plist
    if [[ -f "$MIHOMO_PLIST" ]]; then
        rm -f "$MIHOMO_PLIST"
        info "$(_ removed_plist)"
    fi

    # Remove service script
    if [[ -f "$MIHOMO_SERVICE_SCRIPT" ]]; then
        rm -f "$MIHOMO_SERVICE_SCRIPT"
        info "$(_ removed_service_script)"
    fi

    # Remove config directory
    if [[ -d "$MIHOMO_CONFIG_DIR" ]]; then
        if confirm "$(_ remove_config_confirm)"; then
            rm -rf "$MIHOMO_CONFIG_DIR"
            info "$(_ removed_config_dir)"
        fi
    fi

    # Remove binary
    if [[ -f "$MIHOMO_BIN" ]]; then
        if [[ -w "$MIHOMO_BIN" ]]; then
            rm -f "$MIHOMO_BIN"
        else
            sudo rm -f "$MIHOMO_BIN"
        fi
        info "$(_ removed_binary "$MIHOMO_BIN")"
    fi

    success "$(_ uninstall_success)"
}

# ---------------------------------------------------------------------------
# Main Menu
# ---------------------------------------------------------------------------

show_menu() {
    clear
    print ""
    print "${BOLD}╔═══════════════════════════════════════════════════════╗${NC}"
    print "${BOLD}║     $(_ app_title)     ║${NC}"
    print "${BOLD}╚═══════════════════════════════════════════════════════╝${NC}"
    print ""

    show_status

    print ""
    print "  ${BOLD}[1]${NC} $(_ menu_install)"
    print "        $(_ menu_install_desc)"
    print ""
    print "  ${BOLD}[2]${NC} $(_ menu_import)"
    print "        $(_ menu_import_desc)"
    print ""
    print "  ${BOLD}[3]${NC} $(_ menu_select)"
    print "        $(_ menu_select_desc)"
    print ""
    print "  ${BOLD}[4]${NC} $(_ menu_start)"
    print "        $(_ menu_start_desc)"
    print ""
    print "  ${BOLD}[5]${NC} $(_ menu_stop)"
    print "        $(_ menu_stop_desc)"
    print ""
    print "  ${BOLD}[6]${NC} $(_ menu_panel)"
    print "        $(_ menu_panel_desc)"
    print ""
    print "  ${BOLD}[7]${NC} $(_ menu_uninstall)"
    print "        $(_ menu_uninstall_desc)"
    print ""
    print "  ${BOLD}[8]${NC} $(_ menu_language)"
    print "        $(_ menu_language_desc)"
    print ""
    print "  ${BOLD}[0]${NC} $(_ menu_exit)"
    print ""
    print "${BOLD}───────────────────────────────────────────────────────${NC}"
    print -n "${CYAN}$(_ menu_prompt): ${NC}"
}

main() {
    while true; do
        show_menu
        local choice
        read -r choice

        case "$choice" in
            1) install_mihomo; press_enter ;;
            2) import_subscription; press_enter ;;
            3) select_config; press_enter ;;
            4) install_service; press_enter ;;
            5) stop_service; press_enter ;;
            6) open_panel; press_enter ;;
            7) uninstall_all; press_enter ;;
            8) select_language; press_enter ;;
            0|q|Q)
                print ""
                print "${GREEN}$(_ goodbye)${NC}"
                print ""
                exit 0
                ;;
            *)
                error "$(_ invalid_option)"
                sleep 1
                ;;
        esac
    done
}

main "$@"
