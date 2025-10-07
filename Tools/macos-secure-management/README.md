# macos-secure-management

Generic, **PCI/CIS-aligned** macOS hardening + Intune MDM setup + local automation script.

## Contents
- `macos-security-hardening.md` — Practical baseline + audit mapping (CIS/PCI)  
- `macos-management-intune-setup.md` — End-to-end Intune enrollment & profiles  
- `secure-mac.sh` — Idempotent local hardening script (run with `sudo`)

## Quick Start
```bash
# 1) Review the docs
open macos-security-hardening.md
open macos-management-intune-setup.md

# 2) (Optional) Run local hardening if MDM not yet available
chmod +x secure-mac.sh
sudo ./secure-mac.sh
```

> Prefer MDM (Intune/Jamf/Kandji/Mosyle) profiles for enforcement and auditability.
