# Kibana KQL Queries — SSH Brute Force Investigation

Open Kibana → Discover (or Security → Explore)
Index pattern: `soc-lab-*`

---

## 1. Find all failed SSH logins

```kql
message: "Failed password" AND program: "sshd"
```

---

## 2. Count failed logins by source IP (top attackers)

```kql
message: "Failed password" AND program: "sshd"
```
Then: Visualize → Aggregation by `src_ip.keyword`

---

## 3. Detect brute force threshold (>10 failures from same IP)

```kql
message: "Failed password" AND src_ip: "172.16.0.10"
```

---

## 4. Find the successful login after brute force

```kql
message: "Accepted password" AND program: "sshd" AND src_ip: "172.16.0.10"
```

---

## 5. Full timeline for attacker IP

```kql
src_ip: "172.16.0.10"
```
Sort by `@timestamp` ascending.

---

## 6. Find new user creation (persistence)

```kql
message: "new user" AND program: "useradd"
```

---

## 7. Find sudo commands run by attacker

```kql
program: "sudo" AND (username: "john" OR username: "hacker99")
```

---

## 8. Complete attack timeline query

```kql
(program: "sshd" OR program: "sudo" OR program: "useradd") 
AND (src_ip: "172.16.0.10" OR username: "john" OR username: "hacker99")
```

---

## Elastic SIEM — Threshold Rule

Create in: Security → Rules → Create New Rule → Threshold

```json
{
  "name": "SSH Brute Force Detected",
  "description": "More than 10 failed SSH logins from the same IP in 1 minute",
  "query": "event.dataset: system.auth AND system.auth.ssh.event: Failed",
  "threshold": {
    "field": "source.ip",
    "value": 10
  },
  "time_window": "1m",
  "severity": "high",
  "risk_score": 73
}
```

---

## Splunk SPL Equivalent Queries

```spl
index=soc-lab sourcetype=syslog "Failed password"
| stats count by src_ip
| where count > 10
| sort -count
```

```spl
index=soc-lab sourcetype=syslog "Accepted password"
| eval src_ip=mvindex(split(message," "),10)
| table _time, src_ip, user, message
```
