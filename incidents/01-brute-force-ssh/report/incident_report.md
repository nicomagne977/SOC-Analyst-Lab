# Incident Report — IR-2026-001

| Field | Value |
|-------|-------|
| **Incident ID** | IR-2026-001 |
| **Date Detected** | 2026-05-28 14:37:00 |
| **Date Created** | 2026-05-28 |
| **Severity** | HIGH |
| **Status** | Contained |
| **Analyst** | [Your Name] |
| **Classification** | Unauthorized Access / Brute Force |

---

## 1. Executive Summary

On May 28, 2026 at approximately 14:37, Wazuh and Elastic SIEM generated high-severity alerts indicating a successful SSH brute-force attack against host `ubuntu-victim` (172.16.0.20). The attacker originated from IP `172.16.0.10` (internal attacker VM). After approximately 347 failed authentication attempts over 3 minutes, the attacker successfully authenticated as user `john` and proceeded to create a backdoor account (`hacker99`) for persistent access.

---

## 2. Detection

**Alert Source:** Wazuh Rule 100003 + Elastic Threshold Rule "SSH Brute Force Detected"

**Alert Details:**
- Rule: Multiple failed SSH authentication attempts followed by successful login
- Threshold exceeded: 347 failed attempts (threshold: 10 in 60s)
- First alert: 14:37:00
- Time to detect from first attack: 5 minutes

---

## 3. Timeline

| Time | Event |
|------|-------|
| 14:32:10 | First failed SSH login from 172.16.0.10 |
| 14:32:10–14:34:47 | 347 failed login attempts (brute force) |
| 14:35:02 | **Successful SSH login as user "john"** |
| 14:35:15 | Attacker runs discovery commands (id, whoami, uname) |
| 14:35:40 | **Attacker creates backdoor account "hacker99"** |
| 14:36:01 | Attacker SSH session as "hacker99" |
| 14:37:00 | Wazuh alert fires (5 min delay — threshold window) |
| 14:37:05 | Elastic SIEM correlation rule triggers |
| 14:37:10 | Analyst begins investigation |

---

## 4. Scope & Impact

**Affected Systems:**
- `ubuntu-victim` (172.16.0.20) — compromised host

**Compromised Accounts:**
- `john` — authenticated via brute force (weak password: `password123`)
- `hacker99` — backdoor account created by attacker

**Data Accessed:**
- System information (`uname -a`, `/etc/passwd`, `/etc/os-release`)
- Home directory listing

**Actions Taken by Attacker:**
1. System discovery
2. Created persistence account `hacker99`
3. Established second SSH session as backdoor account

---

## 5. Root Cause Analysis

| Factor | Finding |
|--------|---------|
| **Initial vector** | SSH exposed with weak credentials |
| **Enabling vulnerability** | User `john` had password `password123` (in rockyou.txt) |
| **No lockout policy** | SSH allowed unlimited attempts (no fail2ban / pam_tally) |
| **Missing MFA** | SSH password-only, no public key requirement |
| **Detection gap** | 5-minute delay between attack start and alert |

---

## 6. Indicators of Compromise (IOCs)

| Type | Value | Context |
|------|-------|---------|
| Source IP | 172.16.0.10 | Attacker machine |
| Username | john | Brute-forced account |
| Username | hacker99 | Backdoor account created by attacker |
| Tool signature | hydra | User-agent pattern in logs |
| Log pattern | "Failed password" × 347 | Brute force evidence |
| Command | `adduser hacker99` | Persistence evidence |

---

## 7. Containment Actions

- [ ] **Immediate:** Block IP 172.16.0.10 at firewall
- [ ] Lock compromised accounts: `passwd -l john && passwd -l hacker99`
- [ ] Kill active SSH sessions: `who` → `pkill -9 -u hacker99`
- [ ] Delete backdoor account: `userdel -r hacker99`
- [ ] Force password reset for `john`
- [ ] Review all sudo activity since 14:35:02

```bash
# Commands to run on victim host
sudo passwd -l john
sudo passwd -l hacker99
sudo pkill -u hacker99
sudo userdel -r hacker99
sudo grep "hacker99\|john" /var/log/auth.log > evidence/john_hacker99_actions.log
```

---

## 8. Eradication & Recovery

1. Audit all user accounts: `awk -F: '($3 >= 1000)' /etc/passwd`
2. Check for cron jobs added by attacker: `crontab -u hacker99 -l`
3. Check for SUID binaries: `find / -perm -4000 2>/dev/null`
4. Verify `/etc/sudoers` was not modified: `grep hacker99 /etc/sudoers`
5. Reset `john`'s password to a strong one (or disable password auth)
6. Enable fail2ban:
   ```bash
   sudo apt install fail2ban
   sudo systemctl enable fail2ban --now
   ```
7. Restrict SSH to key-based authentication only:
   ```bash
   # /etc/ssh/sshd_config
   PasswordAuthentication no
   PubkeyAuthentication yes
   ```

---

## 9. Lessons Learned

**What went well:**
- SIEM successfully detected the attack pattern
- Wazuh rule correctly correlated brute force → success

**What needs improvement:**
| Gap | Recommendation |
|-----|----------------|
| Weak password policy | Enforce minimum complexity, ban rockyou passwords |
| No SSH lockout | Deploy fail2ban with 3-attempt threshold |
| SSH password auth | Migrate to key-only authentication |
| Detection delay | Reduce alert threshold from 10 to 5 attempts |
| No IP allowlist | Restrict SSH to known management IPs |

**MITRE ATT&CK Mitigations:**
- M1032 — Multi-factor Authentication for SSH
- M1027 — Password Policies
- M1036 — Account Use Policies (lockout)

---

## 10. Appendix

### Auth.log Evidence
See `../logs/auth.log.sample`

### Kibana Screenshots
*(Add screenshots of your Kibana dashboard and alerts here)*

### References
- [MITRE T1110.001](https://attack.mitre.org/techniques/T1110/001/)
- [MITRE T1021.004](https://attack.mitre.org/techniques/T1021/004/)
- [NIST Incident Handling Guide SP 800-61](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-61r2.pdf)
