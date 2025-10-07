# macOS Management with Microsoft Intune (Generic, MDM-First)

**Goal:** Enroll macOS devices into Intune, enforce a secure baseline with configuration profiles, and prove compliance for audits (PCI/CIS).  
**Prereqs:** Microsoft Intune (Business/Enterprise), Azure AD/Entra ID, Apple Business Manager (ABM) or Apple School Manager (ASM), Apple Push Notification service (APNs) certificate.

---

## 1) High-Level Flow

1. **Connect Apple Business Manager (ABM) to Intune**  
   - In ABM: *Settings → MDM Servers* → Add → Download server token (.p7m).  
   - In Intune: *Devices → iOS/iPadOS/macOS enrollment → Apple enrollment → Enrollment program tokens* → Upload ABM token and assign to MDM.

2. **Enable Automated Device Enrollment (ADE)** for Macs purchased via ABM/DEP.  
   - Define enrollment profiles (user affinity, lock screen message, pre-provisioned accounts if needed).

3. **Configure Compliance Policies** (macOS)  
   - Encryption required (FileVault)  
   - OS version minimum (e.g., macOS 13.x+)  
   - Password required, minimum length/complexity  
   - Firewall enabled  
   - Device not jailbroken (not applicable to macOS, but keep template tidy)

4. **Configure Device Profiles** (Configuration Profiles)  
   - **FileVault**: enable + escrow PRK to Intune.  
   - **Passcode/Password**: complexity, auto-lock, screensaver.  
   - **Firewall**: enable + stealth mode.  
   - **Gatekeeper**: App Store + Identified developers.  
   - **Restrictions**: disable guest login; control sharing features.  
   - **Software Update**: automatic updates.  
   - **Defender/EDR**: onboarding profiles (if using MDE).

5. **Conditional Access** (optional but recommended)  
   - Require compliant device for M365/O365 and internal apps.

6. **Company Portal** install (for user-driven enrollment).

---

## 2) Create Key Profiles in Intune

> Intune Admin Center → **Devices → macOS → Configuration** → **Create**

### 2.1 FileVault (Settings Catalog)
- **Enable** FileVault: *On*
- **Personal Recovery Key**: Enable + escrow to Intune
- **Show recovery key at login**: Optional
- **Deferral**: On first login or next logout
- **Escrow Location Description**: Your helpdesk verbiage
- **Verification**: Intune device report should show *Encryption: Encrypted*; collect FK/PRK escrowed status

### 2.2 Passcode / Screen Lock (Settings Catalog)
- **Password Required**: On
- **Minimum length**: e.g., 12
- **Complexity**: Alphanumeric
- **Auto-lock** (screensaver): 15 minutes or less
- **Require password after sleep**: Immediate

### 2.3 Firewall (Preferences)
- **Enable Firewall**: On
- **Block all incoming**: As policy allows
- **Enable stealth mode**: On

### 2.4 Gatekeeper (Settings Catalog)
- **Allow apps downloaded from**: App Store and identified developers

### 2.5 Restrictions (Settings Catalog)
- **Disable Guest User**: On
- **AirDrop**: Off (if policy requires)
- **Screen Sharing / Remote Mgmt**: Disable unless required

### 2.6 Software Update
- **Automatically check for updates**: On
- **Download new updates when available**: On
- **Install macOS updates**: On
- **Install app updates from App Store**: On

### 2.7 Microsoft Defender for Endpoint (Optional but recommended)
- **Onboard** via Intune by deploying:  
  - Microsoft Defender for Endpoint app (PKG)  
  - Onboarding plist/JSON as a profile  
  - PPPC profile for Full Disk Access permissions

---

## 3) Compliance Policy (macOS)

**Devices → macOS → Compliance policies → Create**  
- Require FileVault **Enabled**  
- Minimum OS version (e.g., 13.6)  
- System Integrity Protection **Enabled** (if available in compliance)  
- Firewall **Enabled**  
- Password settings meet policy  
- **Actions for noncompliance**: mark noncompliant immediately + email user + block via Conditional Access

---

## 4) Conditional Access (Optional)

**Entra ID → Security → Conditional Access → New policy**  
- Assign to users/groups with Macs  
- Cloud apps: All or select sensitive apps  
- **Grant**: Require device to be **marked as compliant**

---

## 5) Enrollment Options

- **Automated Device Enrollment (ADE/DEP):** Zero‑touch for ABM‑purchased Macs.  
- **User‑Driven Enrollment:** Users install **Company Portal**, sign in, and follow prompts.  
- **Bulk Provisioning:** Use ADE with a provisioning user and post-enrollment script packages.

---

## 6) Verification & Troubleshooting Commands (on the Mac)

```bash
# Intune MDM status (profiles, mdmclient)
profiles status -type enrollment
profiles list

# Company Portal logs
cp ~/Library/Logs/Microsoft/Intune/ -R ~/Desktop/IntuneLogs

# FileVault status
fdesetup status

# Firewall status
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate

# Gatekeeper status
spctl --status

# Software Update prefs (partial)
defaults read /Library/Preferences/com.apple.SoftwareUpdate
```

---

## 7) Reporting & Evidence

- Export Intune **Device Compliance** and **Device Configuration** reports (CSV) for audit evidence.  
- Capture screenshots of **FileVault escrow** status and profile assignment.  
- Retain **Conditional Access** policy export (JSON) and change tickets.

---

## 8) Appendix: Profile Scoping Tips

- Use **Security Groups** or **Dynamic device groups** (device.model, enrollmentProfileName).  
- Create **Rings** (Pilot → Broad) for OS updates.  
- For exceptions (e.g., engineering Macs), clone baseline and relax only the required items, with ticket approval and expiration.

---

## 9) Revision History

- v1.0 — Initial generic Intune macOS guide (2025-10-07)
