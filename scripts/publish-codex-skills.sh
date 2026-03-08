#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE_ROOT="${REPO_ROOT}/codex/skills"
MANIFEST_DIR="${REPO_ROOT}/codex/manifests"

DEST_CODEX_HOME="${CODEX_HOME:-${HOME}/.codex}"
DEST_ROOT="${DEST_CODEX_HOME}/skills"
MANIFEST_NAME="global-candidates"
DRY_RUN=0
SKILL_CSV=""

usage() {
  cat <<'EOF'
Usage:
  publish-codex-skills.sh [--dry-run] [--codex-home PATH] [--manifest NAME] [--skills skill-a,skill-b]

Options:
  --dry-run             Show what would be synced without changing files
  --codex-home PATH     Override Codex home directory (default: $CODEX_HOME or ~/.codex)
  --manifest NAME       Manifest name under codex/manifests without .txt (default: global-candidates)
  --skills CSV          Explicit comma-separated skill list; overrides --manifest
  -h, --help            Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --codex-home)
      DEST_CODEX_HOME="$2"
      DEST_ROOT="${DEST_CODEX_HOME}/skills"
      shift 2
      ;;
    --manifest)
      MANIFEST_NAME="$2"
      shift 2
      ;;
    --skills)
      SKILL_CSV="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

collect_skills_from_manifest() {
  local manifest_path="${MANIFEST_DIR}/${MANIFEST_NAME}.txt"
  [[ -f "${manifest_path}" ]] || {
    echo "Manifest not found: ${manifest_path}" >&2
    exit 1
  }

  grep -v '^[[:space:]]*#' "${manifest_path}" | grep -v '^[[:space:]]*$'
}

if [[ -n "${SKILL_CSV}" ]]; then
  IFS=',' read -r -a SKILLS <<< "${SKILL_CSV}"
else
  mapfile -t SKILLS < <(collect_skills_from_manifest)
fi

[[ ${#SKILLS[@]} -gt 0 ]] || {
  echo "No skills selected." >&2
  exit 1
}

mkdir -p "${DEST_ROOT}"

sync_skill() {
  local skill="$1"
  local src="${SOURCE_ROOT}/${skill}"
  local dst="${DEST_ROOT}/${skill}"

  [[ -d "${src}" ]] || {
    echo "Missing source skill: ${src}" >&2
    exit 1
  }

  if [[ ${DRY_RUN} -eq 1 ]]; then
    echo "Would sync ${skill}: ${src} -> ${dst}"
    return
  fi

  mkdir -p "${dst}"

  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "${src}/" "${dst}/"
  else
    rm -rf "${dst}"
    mkdir -p "${dst}"
    cp -R "${src}/." "${dst}/"
  fi

  echo "Synced ${skill}"
}

for skill in "${SKILLS[@]}"; do
  sync_skill "${skill}"
done
