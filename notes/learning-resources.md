# Learning Resources — SOC Analyst Path

## Free Labs & Practice

| Platform | URL | Best For |
|----------|-----|---------|
| TryHackMe | tryhackme.com | Guided beginner rooms |
| Hack The Box | hackthebox.com | More realistic machines |
| Blue Team Labs Online | blueteamlabs.online | Specifically SOC/blue team |
| CyberDefenders | cyberdefenders.org | DFIR & SOC challenges |
| DFIR.training | dfir.training | Incident response |

## Recommended TryHackMe Rooms (in order)

1. SOC Level 1 learning path
2. Splunk: Basics
3. Investigating with Splunk
4. Elastic SIEM Fundamentals
5. Wazuh
6. Incident Response Fundamentals

## Certifications Roadmap

```
[Beginner]
CompTIA Security+ → CompTIA CySA+ → 

[SIEM Specific]
Splunk Core Certified User → Splunk Core Certified Power User

[Advanced]
GIAC GCIH (Incident Handler) → GIAC GCIA (Intrusion Analyst)
```

## Key Concepts to Master

### Log Sources
- `/var/log/auth.log` — SSH, sudo, login events
- `/var/log/syslog` — General system events
- `/var/log/audit/audit.log` — Detailed audit trail
- Windows Event Log IDs:
  - 4624 — Successful logon
  - 4625 — Failed logon
  - 4688 — Process creation
  - 4698 — Scheduled task created

### SIEM Query Languages
- **KQL** (Kibana) — `field: value AND field2: value2`
- **SPL** (Splunk) — `index=main sourcetype=syslog | stats count by src_ip`
- **Sigma rules** — Generic detection format (converts to KQL/SPL)

### MITRE ATT&CK Framework
- Learn the 14 tactics: Reconnaissance → Exfiltration → Impact
- Map every incident to techniques
- Use ATT&CK Navigator: https://mitre-attack.github.io/attack-navigator/

### Network Analysis
- Understand TCP/UDP/ICMP in Wireshark
- Know what normal traffic looks like (baseline)
- Suspicious patterns: port scans, large transfers, beaconing, DNS tunneling

## Tools to Practice

| Tool | Purpose | Where to Learn |
|------|---------|----------------|
| Splunk | SIEM | splunk.com/training (free) |
| Elastic/Kibana | SIEM | elastic.co/training |
| Wazuh | HIDS | documentation.wazuh.com |
| Wireshark | Packet analysis | wireshark.org/docs |
| Volatility | Memory forensics | volatilityfoundation.org |
| Autopsy | Disk forensics | sleuthkit.org |
| YARA | Malware detection | github.com/VirusTotal/yara |
| Sigma | Detection rules | github.com/SigmaHQ/sigma |
