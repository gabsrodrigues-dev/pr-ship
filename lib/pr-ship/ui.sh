#!/usr/bin/env bash
# Terminal UI helpers for pr-ship.
# Output is append-only: nothing clears the screen. A running step is
# printed once and, on an interactive terminal, finished in place.

ui_is_tty() {
  [[ -t 1 ]] && [[ "${TERM:-dumb}" != "dumb" ]]
}

ui_supports_color() {
  ui_is_tty && [[ -z "${NO_COLOR:-}" ]]
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
  UI_STEP_OPEN=0
  UI_STEP_MSG=""
}

ui_header() {
  echo "${UI_C_BOLD}${UI_C_CYAN}==>${UI_C_RESET} ${UI_C_BOLD}$*${UI_C_RESET}"
}

ui_kv() {
  # Pad by character count (printf %-Ns pads by bytes, breaking UTF-8 labels).
  local key="$1" pad=""
  local n=$(( 24 - ${#key} ))
  (( n > 0 )) && printf -v pad "%*s" "$n" ""
  printf "    %s%s%s%s %s%s%s\n" "${UI_C_DIM}" "$key" "$pad" "${UI_C_RESET}" "${UI_C_BOLD}" "$2" "${UI_C_RESET}"
}

ui_info() {
  echo "${UI_C_BLUE}i${UI_C_RESET} $*"
}

ui_ok() {
  echo "${UI_C_GREEN}✔${UI_C_RESET} $*"
}

ui_warn() {
  echo "${UI_C_YELLOW}!${UI_C_RESET} $*" >&2
}

ui_err() {
  echo "${UI_C_RED}✖${UI_C_RESET} ${UI_C_BOLD}$*${UI_C_RESET}" >&2
}

# Indented, dimmed line printed under a step (e.g. error details).
ui_detail() {
  echo "      ${UI_C_DIM}$*${UI_C_RESET}" >&2
}

# Starts a step. On a TTY the line stays open so ui_step_ok/ui_step_fail
# can finish it in place; otherwise it is printed as its own line.
ui_step() {
  UI_STEP_MSG="$*"
  if ui_is_tty; then
    printf "  %s…%s %s" "${UI_C_YELLOW}" "${UI_C_RESET}" "${UI_STEP_MSG}"
    UI_STEP_OPEN=1
  else
    echo "  … ${UI_STEP_MSG}"
  fi
}

_ui_step_close() {
  if [[ "${UI_STEP_OPEN:-0}" == 1 ]]; then
    printf "\r\033[K"
    UI_STEP_OPEN=0
  fi
}

# ui_step_ok [message] [extra]
ui_step_ok() {
  local msg="${1:-$UI_STEP_MSG}"
  local extra="${2:-}"
  _ui_step_close
  if [[ -n "$extra" ]]; then
    printf "  %s✔%s %s  %s%s%s\n" "${UI_C_GREEN}" "${UI_C_RESET}" "$msg" "${UI_C_DIM}" "$extra" "${UI_C_RESET}"
  else
    printf "  %s✔%s %s\n" "${UI_C_GREEN}" "${UI_C_RESET}" "$msg"
  fi
}

# ui_step_fail [message]
ui_step_fail() {
  local msg="${1:-$UI_STEP_MSG}"
  _ui_step_close
  printf "  %s✖%s %s%s%s\n" "${UI_C_RED}" "${UI_C_RESET}" "${UI_C_BOLD}" "$msg" "${UI_C_RESET}" >&2
}
