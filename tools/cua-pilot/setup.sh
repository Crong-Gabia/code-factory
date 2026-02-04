#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

VM_PREFIX="opencode-cua"
GOLDEN_NAME="${VM_PREFIX}-golden"
DEV1_NAME="${VM_PREFIX}-dev-1"
DEV2_NAME="${VM_PREFIX}-dev-2"

UNATTENDED_PRESET="sequoia"
CHECK_ONLY=false
AUTO_YES=false
LAUNCH_WEB=true

MIN_MACOS_MAJOR=13
MIN_DISK_GB=40
RECOMMENDED_DISK_GB=80
RECOMMENDED_RAM_GB=16

usage() {
  cat <<'EOF'
Usage:
  bash tools/cua-pilot/setup.sh [options]

Options:
  --check-only                 Only run host preflight checks
  --yes                        Non-interactive (assume yes)
  --no-web                      Do not launch OpenCode Web UI
  --vm-prefix <prefix>          VM name prefix (default: opencode-cua)
  --unattended <preset>         Lume unattended preset (default: sequoia; also: tahoe)

What it does:
  1) Preflight checks (Apple Silicon + macOS >= 13 + disk/RAM)
  2) Install Lume if missing
  3) Create golden VM (unattended, SSH enabled) and clone 2 dev VMs
  4) Optionally launch OpenCode Web UI on host (tools/opencode-web)
EOF
}

log() { echo "[cua-pilot] $*"; }
warn() { echo "[cua-pilot][WARN] $*" >&2; }
die() { echo "[cua-pilot][FAIL] $*" >&2; exit 1; }

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || die "Missing required command: $cmd"
}

confirm() {
  local msg="$1"
  if $AUTO_YES; then
    return 0
  fi
  echo -n "$msg [y/N]: " >&2
  local ans=""
  IFS= read -r ans
  [[ "${ans,,}" == "y" || "${ans,,}" == "yes" ]]
}

get_macos_major() {
  local v
  v="$(sw_vers -productVersion)"
  echo "${v%%.*}"
}

get_free_disk_gb() {
  # Use / volume free space in GB (rounded down)
  local kb
  kb="$(df -Pk / | awk 'NR==2 {print $4}')"
  echo "$((kb / 1024 / 1024))"
}

get_ram_gb() {
  local bytes
  bytes="$(sysctl -n hw.memsize 2>/dev/null || echo 0)"
  echo "$((bytes / 1024 / 1024 / 1024))"
}

preflight() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    die "This pilot targets macOS hosts only. Detected: $(uname -s)"
  fi

  local arch
  arch="$(uname -m)"
  if [[ "$arch" != "arm64" ]]; then
    die "Apple Silicon required (arm64). Detected: $arch"
  fi

  require_cmd sw_vers
  require_cmd df
  require_cmd awk
  require_cmd sysctl
  require_cmd curl

  local major
  major="$(get_macos_major)"
  if [[ "$major" -lt "$MIN_MACOS_MAJOR" ]]; then
    die "macOS >= ${MIN_MACOS_MAJOR} required. Detected: $(sw_vers -productVersion)"
  fi

  local free_gb
  free_gb="$(get_free_disk_gb)"
  if [[ "$free_gb" -lt "$MIN_DISK_GB" ]]; then
    die "Not enough free disk space on '/': ${free_gb}GB free (need >= ${MIN_DISK_GB}GB; recommended >= ${RECOMMENDED_DISK_GB}GB)"
  fi
  if [[ "$free_gb" -lt "$RECOMMENDED_DISK_GB" ]]; then
    warn "Low free disk space: ${free_gb}GB free (recommended >= ${RECOMMENDED_DISK_GB}GB). IPSW (~15GB) + VM disk (~50GB+) may fill disk."
  fi

  local ram_gb
  ram_gb="$(get_ram_gb)"
  if [[ "$ram_gb" -lt 8 ]]; then
    die "Not enough RAM: ${ram_gb}GB (need >= 8GB; recommended >= ${RECOMMENDED_RAM_GB}GB)"
  fi
  if [[ "$ram_gb" -lt "$RECOMMENDED_RAM_GB" ]]; then
    warn "Low RAM: ${ram_gb}GB (recommended >= ${RECOMMENDED_RAM_GB}GB). Running a macOS VM may be uncomfortable."
  fi

  log "Preflight OK (arch=arm64, macOS=$(sw_vers -productVersion), disk_free=${free_gb}GB, ram=${ram_gb}GB)"
}

ensure_lume() {
  if command -v lume >/dev/null 2>&1; then
    log "Lume detected: $(lume --version 2>/dev/null || true)"
    return 0
  fi

  log "Lume not found. Installing..."
  warn "Installer runs: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/trycua/cua/main/libs/lume/scripts/install.sh)\""

  if ! confirm "Proceed with Lume install?"; then
    die "Aborted (Lume install declined)"
  fi

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/trycua/cua/main/libs/lume/scripts/install.sh)"

  # Common first-install issue: ~/.local/bin not on PATH
  export PATH="$PATH:$HOME/.local/bin"
  hash -r || true

  command -v lume >/dev/null 2>&1 || die "Lume install finished but 'lume' not found. Ensure ~/.local/bin is in PATH and retry."
  log "Lume installed: $(lume --version 2>/dev/null || true)"
}

vm_exists() {
  local name="$1"
  lume get "$name" >/dev/null 2>&1
}

ensure_vm_golden() {
  if vm_exists "$GOLDEN_NAME"; then
    log "Golden VM exists: $GOLDEN_NAME"
    return 0
  fi

  log "Creating golden VM: $GOLDEN_NAME"
  log "- OS: macOS"
  log "- IPSW: latest (auto-download)"
  log "- Unattended preset: $UNATTENDED_PRESET (creates user 'lume' / password 'lume', enables SSH)"

  lume create "$GOLDEN_NAME" --os macos --ipsw latest --unattended "$UNATTENDED_PRESET"

  log "Golden VM created: $GOLDEN_NAME"
}

ensure_vm_clone() {
  local src="$1"
  local dst="$2"

  if vm_exists "$dst"; then
    log "VM exists: $dst"
    return 0
  fi

  log "Cloning VM: $src -> $dst"
  lume clone "$src" "$dst"
}

maybe_launch_web_ui() {
  if ! $LAUNCH_WEB; then
    log "Skipping OpenCode Web UI launch (--no-web)"
    return 0
  fi

  local opencode_web_dir
  opencode_web_dir="$(cd "../opencode-web" && pwd)" || {
    warn "tools/opencode-web not found; skipping Web UI launch"
    return 0
  }

  if ! command -v docker >/dev/null 2>&1; then
    warn "docker not found; skipping OpenCode Web UI launch"
    return 0
  fi

  log "Launching OpenCode Web UI (host) via tools/opencode-web/run.command"
  bash "$opencode_web_dir/run.command"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --check-only)
      CHECK_ONLY=true
      shift
      ;;
    --yes)
      AUTO_YES=true
      shift
      ;;
    --no-web)
      LAUNCH_WEB=false
      shift
      ;;
    --vm-prefix)
      VM_PREFIX="${2:-}"; [[ -n "$VM_PREFIX" ]] || die "--vm-prefix requires a value"
      GOLDEN_NAME="${VM_PREFIX}-golden"
      DEV1_NAME="${VM_PREFIX}-dev-1"
      DEV2_NAME="${VM_PREFIX}-dev-2"
      shift 2
      ;;
    --unattended)
      UNATTENDED_PRESET="${2:-}"; [[ -n "$UNATTENDED_PRESET" ]] || die "--unattended requires a value"
      shift 2
      ;;
    *)
      die "Unknown arg: $1 (use --help)"
      ;;
  esac
done

preflight

if $CHECK_ONLY; then
  exit 0
fi

ensure_lume

ensure_vm_golden
ensure_vm_clone "$GOLDEN_NAME" "$DEV1_NAME"
ensure_vm_clone "$GOLDEN_NAME" "$DEV2_NAME"

log "VMs ready:"
lume ls || true

cat <<EOF

Next:
- Start a VM: lume run "$DEV1_NAME"
- SSH:       lume ssh "$DEV1_NAME" "whoami"

Note:
- This pilot uses unattended setup so SSH is enabled (user: lume / password: lume).
- Do NOT bake secrets into the golden VM.
EOF

maybe_launch_web_ui
