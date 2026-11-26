# Scenario — Definition of Done

A scenario is marked **✅ Complete** in the main [README](../README.md) only when every box below is ticked. Until then it stays **🚧 In progress**, and this list doubles as its roadmap.

## Checklist

### 1. Header
- [ ] `incidents/0X/README.md` starts with the standard header table (status, MITRE ATT&CK IDs, severity, difficulty, estimated duration, what is missing)
- [ ] Every technique is listed in the *MITRE ATT&CK Mapping* table and linked to attack.mitre.org

### 2. Attack (reproduction)
- [ ] `attack/` contains a script or step-by-step commands that reproduce the scenario in the lab
- [ ] Safety note when the scenario simulates malware or destructive actions

### 3. Logs
- [ ] `logs/` contains a sample of the raw evidence (auth.log, PowerShell, Sysmon, pcap notes…)
- [ ] The sample actually contains the IOCs listed in the README

### 4. Detection
- [ ] At least one detection rule: `detection/wazuh_rule.xml` and/or `detection/elastic_rule.ndjson`
- [ ] Investigation queries in `detection/kibana_queries.md` (KQL, optionally SPL)
- [ ] Detection logic explained in the README (threshold, correlation)

### 5. Report (NIST SP 800-61)
- [ ] `report/incident_report.md` covers Detection, Analysis (IOCs, timeline, scope), Containment, Eradication & Recovery, Lessons Learned

### 6. Dashboard
- [ ] The row in the main README *Scenarios* table is up to date (artifacts + status)

## Roadmap

| Scenario | Remaining work |
|----------|----------------|
| 01 — SSH Brute Force | Commit `detection/elastic_rule.ndjson` (referenced in the README) |
| 02 — Phishing + Malware | Attack script in `attack/`, detection rule, `logs/network_capture.md`, incident report |
| 03 — Lateral Movement | Attack script, sample logs, detection rule, move queries to `detection/kibana_queries.md`, incident report |
