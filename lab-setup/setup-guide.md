# Lab Setup Guide

## Step 1 — Install VirtualBox

Download: https://www.virtualbox.org/wiki/Downloads

Create a Host-Only network: `File > Host Network Manager > Create`
- IP: `172.16.0.1`
- Mask: `255.255.255.0`
- DHCP: disabled

## Step 2 — Create the Victim VM (Ubuntu 22.04)

1. Download Ubuntu 22.04 Server ISO
2. Create VM: 2 CPU, 4GB RAM, 40GB disk
3. Network adapters:
   - Adapter 1: NAT (internet access)
   - Adapter 2: Host-Only (`172.16.0.20`)
4. Install Ubuntu, enable SSH:
   ```bash
   sudo apt update && sudo apt install -y openssh-server
   sudo systemctl enable ssh
   ```
5. Set static IP on the host-only interface:
   ```bash
   sudo nano /etc/netplan/01-netcfg.yaml
   ```
   ```yaml
   network:
     version: 2
     ethernets:
       enp0s8:
         addresses: [172.16.0.20/24]
   ```
   ```bash
   sudo netplan apply
   ```

## Step 3 — Create the Attacker VM (Kali Linux)

1. Download Kali Linux VM: https://www.kali.org/get-kali/#kali-virtual-machines
2. Import in VirtualBox
3. Network adapters:
   - Adapter 1: NAT
   - Adapter 2: Host-Only (`172.16.0.10`)
4. Set static IP:
   ```bash
   sudo nano /etc/network/interfaces
   # Add:
   # auto eth1
   # iface eth1 inet static
   #   address 172.16.0.10
   #   netmask 255.255.255.0
   ```

## Step 4 — Deploy ELK Stack (SIEM)

On your host machine (requires Docker):
```bash
cd tools/elk-setup
docker-compose up -d
```

Access Kibana: http://localhost:5601
- Username: `elastic`
- Password: `changeme`

## Step 5 — Install Wazuh Agent on Victim VM

```bash
# On the victim VM
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring \
  --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" \
  | tee /etc/apt/sources.list.d/wazuh.list
sudo apt update && sudo apt install -y wazuh-agent
sudo WAZUH_MANAGER="172.16.0.1" systemctl restart wazuh-agent
```

## Step 6 — Install Filebeat on Victim VM (sends logs to ELK)

```bash
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.11.0-amd64.deb
sudo dpkg -i filebeat-8.11.0-amd64.deb
sudo cp ../tools/elk-setup/filebeat.yml /etc/filebeat/filebeat.yml
sudo systemctl enable filebeat && sudo systemctl start filebeat
```

## Verify Connectivity

```bash
# From Kali, ping the victim
ping 172.16.0.20

# From victim, check Filebeat is shipping logs
sudo filebeat test output
```

You are now ready to run the incident scenarios in `incidents/`.
