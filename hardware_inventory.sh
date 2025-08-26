#!/bin/bash
# Linux Hardware Inventory Script
# File: hardware_inventory.sh

echo "=== Linux Hardware Inventory Collection ==="
echo "Timestamp: $(date)"
echo "Hostname: $(hostname)"
echo "========================================"

# System Information
echo -e "\n[SYSTEM INFORMATION]"
echo "Manufacturer: $(sudo dmidecode -s system-manufacturer 2>/dev/null || echo 'Unknown')"
echo "Product Name: $(sudo dmidecode -s system-product-name 2>/dev/null || echo 'Unknown')"
echo "Serial Number: $(sudo dmidecode -s system-serial-number 2>/dev/null || echo 'Unknown')"
echo "UUID: $(sudo dmidecode -s system-uuid 2>/dev/null || echo 'Unknown')"

# CPU Information
echo -e "\n[CPU INFORMATION]"
CPU_MODEL=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
CPU_CORES=$(lscpu | grep "^CPU(s):" | cut -d':' -f2 | xargs)
CPU_THREADS=$(lscpu | grep "Thread(s) per core" | cut -d':' -f2 | xargs)
CPU_ARCH=$(lscpu | grep "Architecture" | cut -d':' -f2 | xargs)

echo "CPU Model: $CPU_MODEL"
echo "CPU Cores: $CPU_CORES"
echo "Threads per Core: $CPU_THREADS"
echo "Architecture: $CPU_ARCH"
echo "CPU Frequency: $(lscpu | grep "CPU max MHz" | cut -d':' -f2 | xargs || echo 'Variable')"

# Memory Information
echo -e "\n[MEMORY INFORMATION]"
TOTAL_MEM=$(free -h | grep Mem | awk '{print $2}')
AVAILABLE_MEM=$(free -h | grep Mem | awk '{print $7}')
echo "Total Memory: $TOTAL_MEM"
echo "Available Memory: $AVAILABLE_MEM"

# Memory Module Details
echo -e "\nMemory Modules:"
sudo dmidecode -t memory 2>/dev/null | grep -E "(Size|Speed|Manufacturer)" | grep -v "No Module" | head -9

# Storage Information
echo -e "\n[STORAGE INFORMATION]"
echo "Block Devices:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE | head -10

echo -e "\nDisk Usage:"
df -h | grep -E "^/dev" | head -5

# Network Hardware
echo -e "\n[NETWORK HARDWARE]"
echo "Network Interfaces:"
ip link show | grep -E "^[0-9]" | cut -d':' -f2 | xargs | tr ' ' '\n' | head -5

# PCI Devices
echo -e "\n[PCI DEVICES]"
lspci | head -10

# USB Devices
echo -e "\n[USB DEVICES]"
lsusb | head -10

# Generate CSV output
CSV_FILE="/tmp/hardware_inventory_$(date +%Y%m%d_%H%M%S).csv"
echo "Hostname,Manufacturer,Model,Serial,CPU,Cores,TotalRAM,Architecture,Timestamp" > $CSV_FILE
echo "$(hostname),$(sudo dmidecode -s system-manufacturer 2>/dev/null || echo 'Unknown'),$(sudo dmidecode -s system-product-name 2>/dev/null || echo 'Unknown'),$(sudo dmidecode -s system-serial-number 2>/dev/null || echo 'Unknown'),$CPU_MODEL,$CPU_CORES,$TOTAL_MEM,$CPU_ARCH,$(date)" >> $CSV_FILE

echo -e "\n========================================"
echo "Hardware inventory saved to: $CSV_FILE"
echo "========================================"
