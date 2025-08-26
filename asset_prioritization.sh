#!/bin/bash
# Asset Prioritization Framework
# File: asset_prioritization.sh

echo "=== Asset Prioritization Framework ==="
echo "Timestamp: $(date)"
echo "========================================"

CSV_FILE="/tmp/asset_prioritization_$(date +%Y%m%d_%H%M%S).csv"
echo "AssetName,AssetType,BusinessImpact,DataSensitivity,AvailabilityReq,TotalScore,Priority,Justification" > $CSV_FILE

# Function to calculate priority
calculate_priority() {
    local asset_name="$1"
    local asset_type="$2"
    local business_impact=$3
    local data_sensitivity=$4
    local availability_req=$5
    
    local total_score=$((business_impact + data_sensitivity + availability_req))
    local priority=""
    local justification=""
    
    if [[ $total_score -ge 13 ]]; then
        priority="CRITICAL"
        justification="Mission-critical asset requiring immediate protection"
    elif [[ $total_score -ge 10 ]]; then
        priority="HIGH"
        justification="Important asset requiring enhanced protection"
    elif [[ $total_score -ge 7 ]]; then
        priority="MEDIUM"
        justification="Standard asset requiring normal protection"
    elif [[ $total_score -ge 4 ]]; then
        priority="LOW" 
        justification="Low-impact asset requiring basic protection"
    else
        priority="MINIMAL"
        justification="Minimal impact asset requiring minimal protection"
    fi
    
    echo "$asset_name,$asset_type,$business_impact,$data_sensitivity,$availability_req,$total_score,$priority,$justification" >> $CSV_FILE
}

# Sample asset prioritization
echo "Calculating asset priorities..."

# Critical Infrastructure Assets
calculate_priority "Domain Controller" "Server" 5 5 5
calculate_priority "Database Server" "Server" 5 5 4
calculate_priority "Email Server" "Server" 4 4 4
calculate_priority "Web Server" "Server" 4 3 4

# Network Infrastructure
calculate_priority "Core Router" "Network Device" 5 3 5
calculate_priority "Firewall" "Security Device" 5 4 5
calculate_priority "Network Switch" "Network Device" 4 2 4

# User Endpoints
calculate_priority "CEO Laptop" "Endpoint" 3 4 3
calculate_priority "HR Workstation" "Endpoint" 3 5 3
calculate_priority "Developer Workstation" "Endpoint" 3 3 3
calculate_priority "Standard Workstation" "Endpoint" 2 2 2

# Cloud Services
calculate_priority "AWS Production" "Cloud Service" 5 4 5
calculate_priority "Office365" "Cloud Service" 4 3 4
calculate_priority "Backup Service" "Cloud Service" 3 4 2

# Specialized Equipment
calculate_priority "Security Camera System" "IoT Device" 2 2 3
calculate_priority "HVAC Controller" "OT Device" 3 1 3
calculate_priority "Printer Fleet" "Peripheral" 1 2 1

# Display results
echo -e "\n[ASSET PRIORITIZATION RESULTS]"
echo "Assets sorted by priority score:"

# Sort and display results
sort -t',' -k6 -nr $CSV_FILE | grep -v "AssetName" | while IFS=',' read asset type bi ds ar score priority justification; do
    printf "%-20s %-15s %s (Score: %d)\n" "$asset" "$type" "$priority" "$score"
done

# Generate summary statistics
echo -e "\n[PRIORITY DISTRIBUTION]"
CRITICAL_COUNT=$(grep -c "CRITICAL" $CSV_FILE)
HIGH_COUNT=$(grep -c "HIGH" $CSV_FILE)
MEDIUM_COUNT=$(grep -c "MEDIUM" $CSV_FILE)
LOW_COUNT=$(grep -c "LOW" $CSV_FILE)
MINIMAL_COUNT=$(grep -c "MINIMAL" $CSV_FILE)

echo "Critical Priority: $CRITICAL_COUNT assets"
echo "High Priority: $HIGH_COUNT assets"
echo "Medium Priority: $MEDIUM_COUNT assets"
echo "Low Priority: $LOW_COUNT assets"
echo "Minimal Priority: $MINIMAL_COUNT assets"

# Create priority matrix visualization
MATRIX_FILE="/tmp/priority_matrix_$(date +%Y%m%d_%H%M%S).txt"
cat << 'EOF' > $MATRIX_FILE
ASSET PRIORITY MATRIX

        Low Impact    Medium Impact    High Impact
        (Score 1-2)   (Score 3)        (Score 4-5)
        ┌─────────────┬─────────────┬─────────────┐
Critical│             │             │             │
Avail.  │    LOW      │   MEDIUM    │   HIGH      │
(4-5)   │             │             │             │
        ├─────────────┼─────────────┼─────────────┤
Standard│             │             │             │
Avail.  │   MINIMAL   │    LOW      │   MEDIUM    │
(2-3)   │             │             │             │
        ├─────────────┼─────────────┼─────────────┤
Low     │             │             │             │
Avail.  │   MINIMAL   │   MINIMAL   │    LOW      │
(1)     │             │             │             │
        └─────────────┴─────────────┴─────────────┘

Scoring Criteria:
• Business Impact: 1=Minimal, 2=Low, 3=Medium, 4=High, 5=Critical
• Data Sensitivity: 1=Public, 2=Internal, 3=Restricted, 4=Confidential, 5=Secret
• Availability Req: 1=Best Effort, 2=Standard, 3=Important, 4=Critical, 5=Mission Critical
EOF

echo -e "\n========================================"
echo "Asset prioritization complete!"
echo "Results saved to: $CSV_FILE"
echo "Priority matrix: $MATRIX_FILE"
echo "========================================"
