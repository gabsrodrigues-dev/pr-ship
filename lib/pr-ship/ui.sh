#!/usr/bin/env bash

set -euo pipefail

ui_supports_color() {
  [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]
}

ui_init_colors() {
  if ui_supports_color; then
    UI_C_RESET=$'\033[0m'
    UI_C_BOLD=$'\033[1m'
    UI_C_DIM=$'\033[2m'
    UI_C_RED=$'\033[31m'
    UI_C_GREEN=$'\033[32m'
    UI_C_YELLOW=$'\033[33m'
    UI_C_BLUE=$'\033[34m'
    UI_C_CYAN=$'\033[36m'
  else
    UI_C_RESET=""
    UI_C_BOLD=""
    UI_C_DIM=""
    UI_C_RED=""
    UI_C_GREEN=""
    UI_C_YELLOW=""
    UI_C_BLUE=""
    UI_C_CYAN=""
  fi
}

ui_clear_stage() {
  if [[ -t 1 ]] && command -v clear &>/dev/null; then
    clear
  fi
}

ui_header() {
  local title="$1"
  echo "${UI_C_BOLD}${UI_C_CYAN}==>${UI_C_RESET} ${UI_C_BOLD}${title}${UI_C_RESET}"
  echo ""
}

ui_kv() {
  local key="$1"
  local value="$2"
  printf "%b%s%b %b%s%b\n" "${UI_C_DIM}" "${key}:" "${UI_C_RESET}" "${UI_C_BOLD}" "${value}" "${UI_C_RESET}"
}

ui_info() {
  echo "${UI_C_BLUE}i${UI_C_RESET} $*"
}

ui_ok() {
  echo "${UI_C_GREEN}OK${UI_C_RESET} $*"
}

ui_warn() {
  echo "${UI_C_YELLOW}!${UI_C_RESET} $*"
}

ui_err() {
  echo "${UI_C_RED}ERR${UI_C_RESET} $*"
}
