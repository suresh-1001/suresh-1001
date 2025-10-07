#!/bin/zsh
# secure-mac.sh — Generic macOS hardening script
# Compatible: macOS 12+ (Monterey) to macOS 15+ (Sequoia)
# Usage: sudo ./secure-mac.sh
# Note: Prefer enforcing via MDM where possible. This script is idempotent where feasible.

set -euo pipefail

LOG_FILE="/var/log/secure-mac.log"
DATE_STR="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

log() {
  echo "[$DATE_STR] $1" | tee -a "$LOG_FILE"
}

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Try: sudo $0"
    exit 1
  fi
}

macos_version_check() {
  OS_MAJOR=$(sw_vers -productVersion | cut -d. -f1)
  if [[ "$OS_MAJOR" -lt 12 ]]; then
    log "WARNING: macOS version < 12 detected. Some settings may not apply."
  fi
}

enable_firewall() {
  log "Enabling Application Firewall with stealth + logging..."
  /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
  /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
  /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
  /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | tee -a "$LOG_FILE" || true
}

configure_gatekeeper() {
  log "Enabling Gatekeeper (App Store + Identified Developers)..."
  spctl --master-enable
  spctl --status | tee -a "$LOG_FILE" || true
}

disable_guest_autologin() {
  log "Disabling Guest user and auto login..."
  defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false
  defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser 2>/dev/null || true
}

screen_lock_settings() {
  log "Setting screen lock: require password immediately; idle 15 min..."
  # Require password after sleep/screensaver
  sudo -u "$SUDO_USER" defaults write com.apple.screensaver askForPassword -int 1 || true
  sudo -u "$SUDO_USER" defaults write com.apple.screensaver askForPasswordDelay -int 0 || true

  # Idle & sleep (system-wide)
  pmset -a displaysleep 15
  pmset -a sleep 30
}

disable_remote_services() {
  log "Disabling remote login (SSH) and Apple Remote Desktop if present..."
  systemsetup -setremotelogin off 2>/dev/null || true
  /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop 2>/dev/null || true
}

enable_auto_updates() {
  log "Enabling automatic updates..."
  softwareupdate --schedule on
  defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool true
}

filevault_enable_deferred() {
  # We do not auto-enable FileVault silently to avoid key escrow issues.
  # This defers to next login and writes a temporary PRK file.
  log "Ensuring FileVault is enabled (deferred if needed)..."
  FV_STATUS="$(fdesetup status || true)"
  if [[ "$FV_STATUS" == *"FileVault is On."* ]]; then
    log "FileVault already enabled."
  else
    fdesetup enable -defer /var/root/FileVault.plist -forceatlogin 1 || {
      log "WARNING: Could not defer FileVault enablement. Consider enabling via MDM FileVault payload."
    }
    chmod 600 /var/root/FileVault.plist 2>/dev/null || true
    log "Deferred FileVault enablement configured. Recovery key in /var/root/FileVault.plist (secure this file!)."
  fi
}

report_summary() {
  log "---- SUMMARY ----"
  fdesetup status | tee -a "$LOG_FILE" || true
  /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | tee -a "$LOG_FILE" || true
  spctl --status | tee -a "$LOG_FILE" || true
  defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled 2>/dev/null | tee -a "$LOG_FILE" || true
  pmset -g | grep -E "displaysleep|sleep" | tee -a "$LOG_FILE" || true
  log "Log saved to: $LOG_FILE"
}

main() {
  require_root
  macos_version_check
  enable_firewall
  configure_gatekeeper
  disable_guest_autologin
  screen_lock_settings
  disable_remote_services
  enable_auto_updates
  filevault_enable_deferred
  report_summary
  log "Completed macOS hardening."
}

main "$@"
