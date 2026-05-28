# SOC Analyst Lab

A hands-on home lab simulating real-world security incidents to develop SOC analyst skills. Built progressively from simple to advanced scenarios.

## Objectives

- Build a functional Security Operations Center (SOC) environment at home
- Simulate realistic attack scenarios and generate logs
- Detect, investigate, and respond to incidents using industry tools
- Practice writing professional incident reports

## Lab Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      HOST MACHINE                           │
│                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │   ATTACKER   │    │    VICTIM    │    │     SIEM     │  │
│  │   Kali Linux │───▶│  Ubuntu 22   │───▶│  Elastic /   │  │
│  │  172.16.0.10 │    │  172.16.0.20 │    │   Wazuh      │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│          │                  │                    │          │
│          └──────────────────┴────────────────────┘          │
│                     Internal Network                        │
│                      172.16.0.0/24                          │
└─────────────────────────────────────────────────────────────┘
```

## Tools Used

| Tool | Purpose |
|------|---------|
| Elastic SIEM (ELK) | Log aggregation, correlation, alerting |
| Wazuh | Host IDS/XDR, agent-based monitoring |
| Splunk Free | Log analysis, SPL queries |
| Wireshark / Zeek | Network traffic capture and analysis |
| Kali Linux | Attacker machine |
| VirtualBox / VMware | Hypervisor for VMs |

## Incident Scenarios

| # | Scenario | Difficulty | MITRE ATT&CK |
|---|----------|------------|--------------|
| [01](incidents/01-brute-force-ssh/) | SSH Brute Force + Unauthorized Access | Beginner | T1110.001, T1021.004 |
| [02](incidents/02-phishing-malware/) | Phishing Email + Malware Execution | Intermediate | T1566.001, T1059.001 |
| [03](incidents/03-lateral-movement/) | Lateral Movement + Privilege Escalation | Advanced | T1021, T1548.003 |

## Quick Start

### Prerequisites
- VirtualBox or VMware Workstation
- At least 16GB RAM (8GB minimum)
- 100GB free disk space

### Setup
```bash
# 1. Clone the repo
git clone https://github.com/YOUR_USERNAME/SOC-Analyst-Lab.git
cd SOC-Analyst-Lab

# 2. Deploy the SIEM stack
cd tools/elk-setup
docker-compose up -d

# 3. Follow scenario-specific instructions in incidents/
```

See [lab-setup/setup-guide.md](lab-setup/setup-guide.md) for detailed instructions.

## Incident Reports

Each scenario includes a complete incident report following NIST IR framework:
- **Detection** — How the incident was identified
- **Analysis** — IOCs, timeline, scope
- **Containment** — Actions taken to stop the threat
- **Eradication & Recovery** — Remediation steps
- **Lessons Learned** — What to improve

## Skills Demonstrated

- Log analysis (auth.log, syslog, Windows Event Logs)
- SIEM query writing (KQL, SPL)
- Network traffic analysis (pcap)
- Threat hunting and IOC extraction
- Incident response documentation
- MITRE ATT&CK framework mapping

---

*Built as a learning project for SOC Analyst certification preparation (CompTIA Security+, CySA+, Splunk Core Certified).*
