# Incident 01 — SSH Brute Force + Unauthorized Access

## Scenario Overview

An attacker discovers an internet-facing SSH server and launches an automated brute-force attack using a common password list. After several hundred failed attempts, the attacker successfully authenticates using a weak credential. They then establish persistence and begin internal reconnaissance.

## MITRE ATT&CK Mapping

| Tactic | Technique | ID |
|--------|-----------|-----|
| Credential Access | Brute Force: Password Guessing | T1110.001 |
| Lateral Movement | Remote Services: SSH | T1021.004 |
| Persistence | Create Account | T1136.001 |
| Discovery | System Information Discovery | T1082 |

## Attack Timeline

```
14:32:10  Attacker begins hydra SSH brute force (172.16.0.10 → 172.16.0.20)
14:32:10  Victim SSH service receives first failed login attempt
14:34:47  347 failed attempts logged in auth.log
14:35:02  Successful login: user "john" with password "password123"
14:35:15  Attacker runs: id, whoami, uname -a (discovery)
14:35:40  Attacker creates backdoor user: adduser hacker99
14:36:01  Attacker downloads and executes reverse shell script
14:37:00  Wazuh alert fires: Multiple authentication failures
14:37:05  Elastic SIEM correlation rule triggers: Brute Force Detected
```

## Files

| File | Description |
|------|-------------|
| `attack/simulate_bruteforce.sh` | Script to reproduce the attack (run on Kali) |
| `logs/auth.log.sample` | Sample auth.log with attack evidence |
| `detection/elastic_rule.ndjson` | Elastic detection rule to import |
| `detection/wazuh_rule.xml` | Wazuh custom rule |
| `detection/kibana_queries.md` | KQL queries for investigation |
| `report/incident_report.md` | Full incident report |

## How to Run This Scenario

### Step 1 — Prepare the Victim
```bash
# On Ubuntu victim VM — create a weak-password user
sudo useradd -m -s /bin/bash john
echo "john:password123" | sudo chpasswd
```

### Step 2 — Launch the Attack (from Kali)
```bash
chmod +x attack/simulate_bruteforce.sh
./attack/simulate_bruteforce.sh
```

### Step 3 — Detect in Kibana
Open Kibana → SIEM → Alerts
Or run the KQL queries in `detection/kibana_queries.md`

### Step 4 — Write the Report
Use `report/incident_report.md` as template and fill in your findings.

## Key Indicators of Compromise (IOCs)

| IOC Type | Value | Context |
|----------|-------|---------|
| Source IP | 172.16.0.10 | Attacker machine |
| Username | john | Compromised account |
| Username | hacker99 | Backdoor account created by attacker |
| Command | `adduser hacker99` | Persistence mechanism |
| Log pattern | "Failed password" × 347 | Brute force evidence |

## Detection Logic

**Threshold alert**: More than 5 failed SSH logins from the same IP within 60 seconds

**Correlation**: Failed login burst followed by successful login from same source = confirmed brute force success

## What You'll Learn

- Reading and interpreting `auth.log`
- Writing KQL queries in Kibana
- Understanding Wazuh rule syntax
- Creating a timeline of attacker actions
- Writing a professional incident report
