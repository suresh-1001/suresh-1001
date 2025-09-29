#!/usr/bin/env bash
set -euo pipefail
LOG_DIR="/var/log/sre"; LOG_FILE="$LOG_DIR/patch_update_$(date +%Y%m%d_%H%M%S).log"
SERVICES=("ssh" "cron")
sudo mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "== SRE Patch/Update =="; date -Iseconds; echo "Host: $(hostname)"; echo
echo "[1/6] Pre-checks"; df -h /
if lsof /var/lib/dpkg/lock >/dev/null 2>&1; then echo "apt/dpkg lock present; aborting."; exit 1; fi
echo "[2/6] Service health (pre)"; for s in "${SERVICES[@]}"; do systemctl is-active --quiet "$s" && echo "  $s: active" || echo "  $s: NOT active"; done
echo "[3/6] Update indices"; sudo apt-get update -y
echo "[4/6] Show upgradable (dry-run)"; sudo apt-get --just-print upgrade | sed -n '1,120p'
echo "[5/6] Apply upgrades"; sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
echo "[6/6] Service health (post)"; for s in "${SERVICES[@]}"; do systemctl is-active --quiet "$s" && echo "  $s: active" || (echo "  $s: NOT active"; systemctl status "$s" || true); done
echo; echo "Kernel: $(uname -r)"; echo "Reboot if kernel/libc updated."; echo "Log: $LOG_FILE"
