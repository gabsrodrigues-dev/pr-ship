#!/usr/bin/env bash

set -euo pipefail

INSTALL_PREFIX="/usr"
SHARE_DIR="${INSTALL_PREFIX}/share/pr-ship"
TARGET_USER="${SUDO_USER:-${USER:-}}"
TARGET_HOME="${HOME}"

if [[ -n "$TARGET_USER" ]] && command -v getent &>/dev/null; then
  TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
fi

USER_CONFIG_DIR="${TARGET_HOME}/.config/pr-ship"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
UI_FILE="${SCRIPT_DIR}/lib/pr-ship/ui.sh"

if [[ -f "$UI_FILE" ]]; then
  source "$UI_FILE"
else
  UI_FILE="${SHARE_DIR}/ui.sh"
  if [[ -f "$UI_FILE" ]]; then
    source "$UI_FILE"
  else
    ui_err() { echo "ERR $*"; }
    ui_info() { echo "i $*"; }
    ui_ok() { echo "OK $*"; }
    ui_warn() { echo "! $*"; }
    ui_header() { echo "==> $*"; echo ""; }
    ui_kv() { echo "$1: $2"; }
    ui_clear_stage() { true; }
    ui_init_colors() { true; }
  fi
fi

ui_init_colors

purge_config=false
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo "Usage: sudo bash uninstall.sh [--purge]"
  exit 0
fi

if [[ "${1:-}" == "--purge" ]]; then
  purge_config=true
fi

if [[ $EUID -ne 0 ]]; then
  ui_err "This uninstaller requires root privileges."
  ui_info "Run: sudo bash uninstall.sh"
  exit 1
fi

installed=false
if [[ -f "${INSTALL_PREFIX}/bin/pr-ship" ]] || [[ -d "${SHARE_DIR}" ]]; then
  installed=true
fi

if [[ "$installed" == false ]]; then
  ui_clear_stage
  ui_header "pr-ship uninstall"
  ui_err "pr-ship is not installed"
  ui_info "Nothing to remove"
  echo ""
  exit 1
fi

ui_clear_stage
ui_header "pr-ship uninstall"

ui_info "Removing installed files..."

rm -f "${INSTALL_PREFIX}/bin/pr-ship"
rm -rf "${SHARE_DIR}"

echo ""
ui_ok "pr-ship has been uninstalled"
ui_kv "Binary" "${INSTALL_PREFIX}/bin/pr-ship"
ui_kv "Share dir" "${SHARE_DIR}"

echo ""
if [[ -d "$USER_CONFIG_DIR" ]]; then
  if [[ "$purge_config" == false ]]; then
    ui_warn "User config still exists"
    ui_kv "Config" "${USER_CONFIG_DIR}"
    echo ""
    read -rp "Remove user config too? [y/N] " confirm
    if [[ "$confirm" =~ ^[yY]$ ]]; then
      purge_config=true
    fi
  fi

  if [[ "$purge_config" == true ]]; then
    rm -rf "$USER_CONFIG_DIR"
    ui_ok "User config removed"
    ui_kv "Config" "${USER_CONFIG_DIR}"
  else
    ui_info "User config was kept"
    ui_kv "Config" "${USER_CONFIG_DIR}"
    ui_info "Tip: run 'sudo bash uninstall.sh --purge' to remove it next time"
  fi
else
  ui_info "No user config found"
fi

echo ""
