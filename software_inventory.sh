#!/bin/bash
# Linux Software Inventory Script
# File: software_inventory.sh

echo "=== Linux Software Inventory Collection ==="
echo "Timestamp: $(date)"
echo "========================================"

CSV_FILE="/tmp/software_inventory_$(date +%Y%m%d_%H%M%S).csv"
echo "Name,Version,Description,Source,InstallDate" > $CSV_FILE

# Function to get installation date (approximate)
get_install_date() {
    local package=$1
    if command -v dpkg-query >/dev/null 2>&1; then
        # Debian/Ubuntu systems
        dpkg-query -W -f='${Status} ${Package} ${Version}\n' "$package" 2>/dev/null | grep "^install ok installed" | head -1
    elif command -v rpm >/dev/null 2>&1; then
        # Red Hat/CentOS/Fedora systems  
        rpm -qi "$package" 2>/dev/null | grep "Install Date"
    fi
}

# Debian/Ubuntu Package Inventory
if command -v dpkg >/dev/null 2>&1; then
    echo "Scanning Debian/Ubuntu packages..."
    dpkg -l | grep "^ii" | while read line; do
        PACKAGE=$(echo $line | awk '{print $2}')
        VERSION=$(echo $line | awk '{print $3}')
        DESCRIPTION=$(echo $line | awk '{for(i=4;i<=NF;++i) print $i}' | tr ' ' '_')
        echo "$PACKAGE,$VERSION,$DESCRIPTION,dpkg,$(stat -c %y /var/lib/dpkg/info/$PACKAGE.list 2>/dev/null | cut -d' ' -f1 || echo 'Unknown')" >> $CSV_FILE
    done
    
    # Count packages
    TOTAL_PACKAGES=$(dpkg -l | grep "^ii" | wc -l)
    echo "Total Debian packages: $TOTAL_PACKAGES"

# Red Hat/CentOS/Fedora Package Inventory
elif command -v rpm >/dev/null 2>&1; then
    echo "Scanning RPM packages..."
    rpm -qa --queryformat "%{NAME},%{VERSION}-%{RELEASE},%{SUMMARY},rpm,%{INSTALLTIME:date}\n" >> $CSV_FILE
    
    TOTAL_PACKAGES=$(rpm -qa | wc -l)
    echo "Total RPM packages: $TOTAL_PACKAGES"
fi

# Snap packages
if command -v snap >/dev/null 2>&1; then
    echo "Scanning Snap packages..."
    snap list | tail -n +2 | while read name version rev tracking publisher notes; do
        echo "$name,$version,Snap Package,snap,$(date)" >> $CSV_FILE
    done
    SNAP_COUNT=$(snap list | tail -n +2 | wc -l)
    echo "Total Snap packages: $SNAP_COUNT"
fi

# Flatpak packages
if command -v flatpak >/dev/null 2>&1; then
    echo "Scanning Flatpak packages..."
    flatpak list --app | while IFS=$'\t' read name appid version branch origin; do
        echo "$name,$version,Flatpak Application,flatpak,$(date)" >> $CSV_FILE
    done
    FLATPAK_COUNT=$(flatpak list --app | wc -l)
    echo "Total Flatpak packages: $FLATPAK_COUNT"
fi

# Python packages
if command -v pip3 >/dev/null 2>&1; then
    echo "Scanning Python packages..."
    pip3 list --format=freeze | while IFS='==' read package version; do
        echo "$package,$version,Python Package,pip3,$(date)" >> $CSV_FILE
    done
    PIP_COUNT=$(pip3 list | tail -n +3 | wc -l)
    echo "Total Python packages: $PIP_COUNT"
fi

echo -e "\n========================================"
echo "Software inventory saved to: $CSV_FILE"
echo "Sample entries:"
head -5 $CSV_FILE
echo "..."
echo "========================================"
