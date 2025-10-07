# macOS Security Hardening (Generic, CIS/PCI-Aligned)

**Purpose:** Provide a practical, auditable macOS hardening baseline aligned to CIS Benchmarks (macOS) and PCI DSS v4.0.1.  
**Audience:** IT admins, security, auditors.  
**Applies to:** macOS 12+ (Monterey) through macOS 15+ (Sequoia).

> ✅ Use this doc as both a *how-to* and *evidence checklist*. Where MDM is available (Intune/Jamf/Kandji/Mosyle), prefer configuration profiles for enforcement; where not, use the included `secure-mac.sh`.

---

## 1) Quick Baseline Checklist

| Area | Setting | Target | How | Verify |
|---|---|---|---|---|
| Full Disk Encryption | FileVault | **Enabled** for all users | MDM profile or `fdesetup` | `fdesetup status` |
| Screen Lock | Password after sleep | **Immediate** | MDM or `defaults` | `defaults -currentHost read com.apple.screensaver` |
| Screen Idle | Idle time | **≤ 900s (15 min)** | MDM or `pmset` | `pmset -g` |
| Firewall | Application Firewall | **On + Stealth** | MDM or `socketfilterfw` | `socketfilterfw --getglobalstate` |
| Gatekeeper | Allow apps | **App Store + Identified** | MDM or `spctl` | `spctl --status` |
| OS Patching | Auto updates | **On** | MDM or `softwareupdate` | `defaults read /Library/Preferences/com.apple.SoftwareUpdate` |
| Accounts | Guest login | **Disabled** | MDM or `defaults` | check login window |
| SIP | System Integrity Protection | **Enabled** | NVRAM/Recovery (default) | `csrutil status` |
| Remote Services | Remote login/screen sharing | **Disabled unless required** | MDM or `systemsetup` | `systemsetup -getremotelogin` |
| Logging | Unified logging + retention | **Default or org policy** | MDM or `/etc/asl` (legacy) | `log config` |

---

## 2) PCI DSS 4.0.1 Mapping (Selected)

> This table notes where this baseline supports PCI DSS; always confirm your assessor’s interpretation.

| PCI Req | Intent | Example in this Baseline |
|---|---|---|
| 2.2.1/2.2.4 | System hardening & secure configs | Gatekeeper, firewall, disable guest/remote services, password policies |
| 3.4 | Render PAN unreadable where stored | Not applicable to endpoints by default; if storing PAN (avoid), use FDE & application-level encryption |
| 5.x | Anti-malware/EDR | Use an approved EDR/AV. Microsoft Defender for Endpoint or vendor of choice via MDM |
| 6.2 | Timely patching | Auto updates + MDM patch rings |
| 7.x/8.x | Access controls & auth | Password policy, screen lock, no shared accounts, FileVault keys escrowed |
| 10.x | Logging & monitoring | Unified logging, EDR telemetry, MDM compliance reports |
| 12.x | Security policies & training | Use this doc as SOP; track evidence in change requests |

---

## 3) CIS macOS (Common Items)

This baseline implements common CIS items (naming varies by version):
- Enable Firewall; deny incoming by default; use stealth mode.
- Enable FileVault; escrow personal recovery key in MDM if possible.
- Enforce password-protected screen saver, 15-min idle or less.
- Disable automatic login and Guest account.
- Disable remote services unless required (SSH, Screen Sharing, Remote Apple Events).
- Limit AirDrop, Bluetooth sharing, and screen recording permissions via PPPC profiles.
- Keep OS and App Store updates automatic.
- Restrict external media (USB) where feasible via MDM.

> For a full, version-specific CIS list, use your subscription benchmark and map to the profile items shown below.

---

## 4) How-To: Local Commands (when MDM is not available)

> Run via `sudo` and audit results after each command.

### 4.1 FileVault (FDE)
```bash
# status
fdesetup status

# enable with deferral (user-initiated at next login)
sudo fdesetup enable -defer /var/root/FileVault.plist -forceatlogin 1
# NOTE: Prefer MDM payload to escrow keys. Secure the output plist and rotate recovery keys periodically.
```

### 4.2 Screen Lock & Idle
```bash
# Require password immediately after sleep/screensaver
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Idle to 15 minutes (900 seconds)
sudo pmset -a displaysleep 15
sudo pmset -a sleep 30
```

### 4.3 Firewall & Stealth
```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
```

### 4.4 Gatekeeper (App Store + Identified Developers)
```bash
sudo spctl --master-enable
spctl --status
```

### 4.5 Disable Guest & Auto Login
```bash
sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false
sudo defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser 2>/dev/null || true
```

### 4.6 Remote Services
```bash
# SSH
sudo systemsetup -setremotelogin off
# Screen Sharing (RemoteManagement off via kickstart if previously enabled)
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop 2>/dev/null || true
```

### 4.7 Automatic Updates
```bash
# Newer macOS manage via softwareupdate + preferences
sudo softwareupdate --schedule on
# App Store auto update
sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool true
```

---

## 5) Prefer MDM Configuration Profiles

For durability and auditability, deploy these via MDM (examples in **macos-management-intune-setup.md**):
- FileVault payload with personal recovery key escrow
- Passcode/password policy
- Firewall payload (enabled + stealth)
- Gatekeeper (App Store + Identified)
- Restrictions (disable guest, sharing, AirDrop as policy requires)
- PPPC and Privacy preferences (screen recording, files/folders access)
- Custom configuration: `com.apple.SoftwareUpdate` for automated patching

---

## 6) Verification & Evidence Collection

Capture commands and screenshots:
```bash
# encryption
fdesetup status
diskutil apfs list

# firewall
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate

# gatekeeper
spctl --status

# screen lock
defaults read com.apple.screensaver askForPassword
defaults read com.apple.screensaver askForPasswordDelay
pmset -g | grep -E "displaysleep|sleep"

# accounts
defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled
```

Save artifacts to your evidence repo:
- Command output (text or JSON where applicable)
- MDM compliance report export (CSV/JSON)
- Screenshots of profile enforcement & FileVault escrow status

---

## 7) EDR/Anti‑Malware (Recommended)

Deploy an approved EDR/AV (e.g., Microsoft Defender for Endpoint, CrowdStrike, SentinelOne).  
- Enforce via MDM with device compliance rules.  
- Ensure telemetry is integrated with your SIEM/SOC.  

---

## 8) Exceptions & Change Management

Document justified exceptions (e.g., developer machines needing SSH) via ticket + expiration date.  
Track with an approval workflow and periodic review.

---

## 9) Revision History

- v1.0 — Initial generic baseline (2025-10-07)
