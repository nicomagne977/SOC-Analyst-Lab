# Incident Response Playbook Template

Based on NIST SP 800-61r2 framework.

## Phase 1 — Preparation

Before any incident occurs, ensure:
- [ ] SIEM is operational and ingesting logs
- [ ] Wazuh agents deployed on all hosts
- [ ] Alerting thresholds configured
- [ ] Contact list for escalation is current
- [ ] Forensic tools available (Volatility, Autopsy, Wireshark)

---

## Phase 2 — Detection & Analysis

### Triage Questions
1. What system(s) are affected?
2. What is the attack vector? (network, email, insider)
3. What is the scope? (single host, lateral spread, data exfil)
4. What is the business impact?
5. When did it start? (first IOC timestamp)

### Severity Classification

| Level | Criteria |
|-------|----------|
| CRITICAL | Active breach, data exfil in progress, ransomware |
| HIGH | Confirmed compromise, no active exfil |
| MEDIUM | Suspicious activity, investigation required |
| LOW | Policy violation, failed attack attempt |

### Evidence to Collect
- `auth.log`, `syslog`, `audit.log`
- Process list at time of incident: `ps aux`
- Network connections: `ss -tunapo`
- Running crons: `crontab -l -u root`
- Bash history: `cat ~/.bash_history`
- Hash of modified files

---

## Phase 3 — Containment

### Short-term (immediate, < 1 hour)
- [ ] Isolate affected host from network
- [ ] Block attacker IP at firewall
- [ ] Disable compromised accounts
- [ ] Preserve evidence (do NOT reboot yet)

### Long-term
- [ ] Patch the exploited vulnerability
- [ ] Force password resets for affected accounts
- [ ] Review and harden configurations

---

## Phase 4 — Eradication

- [ ] Remove all malware/backdoors
- [ ] Delete attacker-created accounts
- [ ] Restore files from known-good backup
- [ ] Verify no persistence mechanisms remain
  - Cron jobs
  - Systemd services
  - SUID binaries
  - Modified sudoers

---

## Phase 5 — Recovery

- [ ] Restore system from clean backup OR rebuild
- [ ] Re-enable services one by one
- [ ] Monitor closely for 72 hours
- [ ] Confirm no re-infection

---

## Phase 6 — Lessons Learned

### Post-Incident Review (within 2 weeks)
1. What happened and why?
2. Was detection timely?
3. Was response effective?
4. What would we do differently?

### Metrics to Track
- Time to Detect (TTD)
- Time to Respond (TTR)
- Time to Recover (TTRec)
- Root cause category

---

## Useful Commands Reference

```bash
# Find recently modified files
find / -mtime -1 -type f 2>/dev/null | grep -v proc

# List all users with login shell
awk -F: '($7 != "/usr/sbin/nologin" && $7 != "/bin/false")' /etc/passwd

# Check for SUID files
find / -perm -4000 -type f 2>/dev/null

# Network connections
ss -tunapo

# Listening ports
ss -tlnp

# Active sessions
who -a

# Check cron jobs
for user in $(cut -f1 -d: /etc/passwd); do crontab -u $user -l 2>/dev/null; done
```
