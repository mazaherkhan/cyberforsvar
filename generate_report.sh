#!/bin/bash
# Consolidated Asset Management Report Generator
# File: generate_report.sh

echo "=== NIST CSF 2.0 Asset Management Report Generator ==="
echo "Timestamp: $(date)"
echo "========================================"

REPORT_FILE="/tmp/nist_csf_asset_report_$(date +%Y%m%d_%H%M%S).html"

# Find most recent inventory files
HARDWARE_FILE=$(ls -t /tmp/*hardware_inventory*.csv 2>/dev/null | head -1)
SOFTWARE_FILE=$(ls -t /tmp/*software_inventory*.csv 2>/dev/null | head -1)
NETWORK_FILE=$(ls -t /tmp/network_baseline*.csv 2>/dev/null | head -1)
PRIORITY_FILE=$(ls -t /tmp/asset_prioritization*.csv 2>/dev/null | head -1)

# Count inventoried items
HARDWARE_COUNT=0
SOFTWARE_COUNT=0
NETWORK_HOSTS=0
PRIORITY_ASSETS=0

[[ -f "$HARDWARE_FILE" ]] && HARDWARE_COUNT=$(($(wc -l < "$HARDWARE_FILE") - 1))
[[ -f "$SOFTWARE_FILE" ]] && SOFTWARE_COUNT=$(($(wc -l < "$SOFTWARE_FILE") - 1))
[[ -f "$NETWORK_FILE" ]] && NETWORK_HOSTS=$(($(wc -l < "$NETWORK_FILE") - 1))
[[ -f "$PRIORITY_FILE" ]] && PRIORITY_ASSETS=$(($(wc -l < "$PRIORITY_FILE") - 1))

# Generate HTML Report
cat << EOF > $REPORT_FILE
<!DOCTYPE html>
<html>
<head>
    <title>Gokstad Akademiet - Lab</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1000px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2C3E50; border-bottom: 3px solid #3498DB; padding-bottom: 10px; }
        h2 { color: #34495E; margin-top: 30px; }
        .executive-summary { background: #ECF0F1; padding: 20px; border-radius: 5px; margin: 20px 0; }
        .metric-box { display: inline-block; background: #3498DB; color: white; padding: 20px; margin: 10px; border-radius: 5px; text-align: center; min-width: 120px; }
        .metric-number { font-size: 2em; font-weight: bold; display: block; }
        .metric-label { font-size: 0.9em; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #34495E; color: white; }
        .implemented { color: #27AE60; font-weight: bold; }
        .file-link { background: #E8F6F3; padding: 10px; margin: 5px 0; border-radius: 3px; }
        .timestamp { color: #7F8C8D; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Gokstad Akademiet - Cyberforsvar og sikkerhet</h1>
        <div class="timestamp">Generated: $(date)</div>
        <div class="timestamp">Platform: $(uname -s) $(uname -r)</div>
	<div class="timestamp">Mazaher Kianpour</div>
        
        <div class="executive-summary">
            <h2>NIST CSF 2.0 Asset Management Laboratory Report</h2>
            <p>This report demonstrates successful implementation of NIST Cybersecurity Framework 2.0 Asset Management controls through class exercises.</p>
            
            <div class="metric-box">
                <span class="metric-number">$HARDWARE_COUNT</span>
                <span class="metric-label">Hardware Assets</span>
            </div>
            <div class="metric-box">
                <span class="metric-number">$SOFTWARE_COUNT</span>
                <span class="metric-label">Software Items</span>
            </div>
            <div class="metric-box">
                <span class="metric-number">$NETWORK_HOSTS</span>
                <span class="metric-label">Network Endpoints</span>
            </div>
            <div class="metric-box">
                <span class="metric-number">$PRIORITY_ASSETS</span>
                <span class="metric-label">Prioritized Assets</span>
            </div>
        </div>
        
        <h2>NIST CSF 2.0 Compliance Status</h2>
        <table>
            <tr><th>Subcategory</th><th>Implementation</th><th>Status</th></tr>
            <tr>
                <td><strong>ID.AM-01:</strong> Hardware inventories are maintained</td>
                <td>Automated hardware discovery using system commands and DMI data</td>
                <td class="implemented">✓ IMPLEMENTED</td>
            </tr>
            <tr>
                <td><strong>ID.AM-02:</strong> Software inventories are maintained</td>
                <td>Comprehensive software scanning using package managers and system APIs</td>
                <td class="implemented">✓ IMPLEMENTED</td>
            </tr>
            <tr>
                <td><strong>ID.AM-03:</strong> Network communication baselines are maintained</td>
                <td>Network discovery and port scanning with baseline documentation</td>
                <td class="implemented">✓ IMPLEMENTED</td>
            </tr>
            <tr>
                <td><strong>ID.AM-05:</strong> Assets are prioritized based on criticality</td>
                <td>Risk-based prioritization matrix with scoring methodology</td>
                <td class="implemented">✓ IMPLEMENTED</td>
            </tr>
        </table>
        
        <h2>Implementation Details</h2>
        
        <h3>Hardware Asset Management (ID.AM-01)</h3>
        <p>Implemented automated hardware discovery using platform-specific system commands including <code>dmidecode</code>, <code>lscpu</code>, <code>lshw</code> on Linux and <code>system_profiler</code>, <code>sysctl</code> on macOS. The system captures detailed hardware specifications, serial numbers, and configuration details.</p>
        
        <h3>Software Asset Management (ID.AM-02)</h3>
        <p>Deployed comprehensive software inventory system supporting multiple package managers (dpkg, rpm, snap, flatpak, homebrew) and application discovery methods. The solution provides complete visibility into installed software across different platforms and installation methods.</p>
        
        <h3>Network Communication Baselines (ID.AM-03)</h3>
        <p>Established network communication baselines using nmap for host discovery and port scanning. Created structured documentation of authorized services and communication patterns with baseline configuration files.</p>
        
        <h3>Asset Prioritization (ID.AM-05)</h3>
        <p>Implemented risk-based asset prioritization framework considering business impact, data sensitivity, and availability requirements. Generated priority matrices supporting strategic security investment decisions.</p>
        
        <h2>Generated Artifacts</h2>
EOF

# Add file links if they exist
[[ -f "$HARDWARE_FILE" ]] && echo "        <div class=\"file-link\"><strong>Hardware Inventory:</strong> $HARDWARE_FILE</div>" >> $REPORT_FILE
[[ -f "$SOFTWARE_FILE" ]] && echo "        <div class=\"file-link\"><strong>Software Inventory:</strong> $SOFTWARE_FILE</div>" >> $REPORT_FILE
[[ -f "$NETWORK_FILE" ]] && echo "        <div class=\"file-link\"><strong>Network Baseline:</strong> $NETWORK_FILE</div>" >> $REPORT_FILE
[[ -f "$PRIORITY_FILE" ]] && echo "        <div class=\"file-link\"><strong>Asset Prioritization:</strong> $PRIORITY_FILE</div>" >> $REPORT_FILE

cat << 'EOF' >> $REPORT_FILE
        
        <h2>Recommendations</h2>
        <ul>
            <li><strong>Automation:</strong> Schedule inventory scripts to run weekly for continuous asset visibility</li>
            <li><strong>Integration:</strong> Integrate with CMDB systems for centralized asset management</li>
            <li><strong>Monitoring:</strong> Implement continuous network monitoring for baseline deviation detection</li>
            <li><strong>Governance:</strong> Establish asset management policies and regular review processes</li>
            <li><strong>Security:</strong> Use asset inventories to support vulnerability management and incident response</li>
        </ul>
        
        <h2>Conclusion</h2>
        <p>This laboratory exercise successfully demonstrates implementation of core NIST CSF 2.0 Asset Management controls using practical tools and techniques. The automated inventory systems provide comprehensive visibility into organizational assets while the prioritization framework supports risk-based decision making. These implementations form the foundation for effective cybersecurity asset management programs.</p>
    </div>
</body>
</html>
EOF

echo -e "\n========================================"
echo "CONSOLIDATED REPORT GENERATED!"
echo "Report location: $REPORT_FILE"
echo ""
echo "Files processed:"
[[ -f "$HARDWARE_FILE" ]] && echo "  ✓ Hardware: $HARDWARE_FILE"
[[ -f "$SOFTWARE_FILE" ]] && echo "  ✓ Software: $SOFTWARE_FILE"
[[ -f "$NETWORK_FILE" ]] && echo "  ✓ Network: $NETWORK_FILE"
[[ -f "$PRIORITY_FILE" ]] && echo "  ✓ Priority: $PRIORITY_FILE"
echo ""
echo "Open report with:"
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "  open $REPORT_FILE"
else
    echo "  xdg-open $REPORT_FILE  # or firefox $REPORT_FILE"
fi
echo "========================================"
