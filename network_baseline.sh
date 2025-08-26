#!/bin/bash
# Network Discovery and Baseline Script
# File: network_baseline.sh

echo "=== Network Communication Baseline ==="
echo "Timestamp: $(date)"
echo "========================================"

# Get network configuration
echo -e "\n[NETWORK CONFIGURATION]"
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo "Active Network Interfaces:"
    ifconfig | grep -E "^[a-z]|inet " | head -20
    
    DEFAULT_ROUTE=$(route -n get default 2>/dev/null | grep gateway | awk '{print $2}')
    echo "Default Gateway: $DEFAULT_ROUTE"
    
    # Get network range
    LOCAL_IP=$(ifconfig | grep -E "inet [0-9]" | grep -v "127.0.0.1" | head -1 | awk '{print $2}')
    
else
    # Linux
    echo "Active Network Interfaces:"
    ip addr show | grep -E "^[0-9]|inet " | head -20
    
    DEFAULT_ROUTE=$(ip route | grep default | awk '{print $3}' | head -1)
    echo "Default Gateway: $DEFAULT_ROUTE"
    
    # Get network range
    LOCAL_IP=$(ip route get 8.8.8.8 | grep -oP 'src \K[0-9.]+' | head -1)
fi

echo "Local IP Address: $LOCAL_IP"

# Calculate network range for scanning
if [[ -n "$LOCAL_IP" ]]; then
    NETWORK_BASE=$(echo $LOCAL_IP | cut -d. -f1-3)
    NETWORK_RANGE="${NETWORK_BASE}.0/24"
    echo "Network Range for Scanning: $NETWORK_RANGE"
else
    echo "Could not determine network range automatically"
    NETWORK_RANGE="192.168.1.0/24"  # Default fallback
fi

# Network Discovery using nmap
echo -e "\n[NETWORK DISCOVERY]"
echo "Scanning network range: $NETWORK_RANGE"
echo "This may take a few minutes..."

SCAN_FILE="/tmp/network_scan_$(date +%Y%m%d_%H%M%S).txt"

# Host discovery scan
nmap -sn $NETWORK_RANGE > $SCAN_FILE 2>&1

echo "Active hosts discovered:"
grep -E "Nmap scan report for" $SCAN_FILE | head -10

# Extract just IP addresses for detailed scanning
ACTIVE_IPS=$(grep -E "Nmap scan report for" $SCAN_FILE | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" | head -5)

# Port scanning on discovered hosts
echo -e "\n[PORT SCANNING]"
CSV_FILE="/tmp/network_baseline_$(date +%Y%m%d_%H%M%S).csv"
echo "IP,Hostname,Port,Service,State,Product" > $CSV_FILE

for IP in $ACTIVE_IPS; do
    echo "Scanning ports on $IP..."
    nmap -sS --top-ports 20 -sV $IP | grep -E "^[0-9]" | while read line; do
        PORT=$(echo $line | awk '{print $1}')
        STATE=$(echo $line | awk '{print $2}')
        SERVICE=$(echo $line | awk '{print $3}')
        PRODUCT=$(echo $line | awk '{for(i=4;i<=NF;++i) printf "%s ", $i; print ""}')
        HOSTNAME=$(nslookup $IP 2>/dev/null | grep "name =" | awk '{print $4}' | sed 's/\.$//' || echo "Unknown")
        echo "$IP,$HOSTNAME,$PORT,$SERVICE,$STATE,$PRODUCT" >> $CSV_FILE
    done
done

# Baseline Documentation
BASELINE_FILE="/tmp/network_baseline_$(date +%Y%m%d_%H%M%S).json"
cat << EOF > $BASELINE_FILE
{
    "baseline_date": "$(date -Iseconds)",
    "network_range": "$NETWORK_RANGE",
    "local_ip": "$LOCAL_IP",
    "default_gateway": "$DEFAULT_ROUTE",
    "active_hosts": [
$(echo "$ACTIVE_IPS" | sed 's/^/        "/;s/$/",/' | sed '$ s/,$//')
    ],
    "authorized_ports": {
        "22": "SSH - Secure Shell",
        "53": "DNS - Domain Name System", 
        "80": "HTTP - Web Traffic",
        "443": "HTTPS - Secure Web Traffic",
        "445": "SMB - File Sharing",
        "993": "IMAPS - Secure Email",
        "995": "POP3S - Secure Email"
    },
    "scan_results_file": "$CSV_FILE",
    "notes": "Initial network baseline - $(date)"
}
EOF

echo -e "\n========================================"
echo "Network baseline documentation:"
echo "Scan results: $CSV_FILE"
echo "Baseline config: $BASELINE_FILE"
echo "Raw scan data: $SCAN_FILE"
echo "========================================"
