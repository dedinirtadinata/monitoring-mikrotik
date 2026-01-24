#!/bin/bash
# Script untuk cek OID SNMP MikroTik untuk temperature dan voltage

MIKROTIK_IP="${1:-10.6.86.1}"
COMMUNITY="${2:-monitoring}"

echo "Checking SNMP OIDs for MikroTik at $MIKROTIK_IP..."
echo ""

echo "=== Checking Health OID Base ==="
snmpwalk -v 2c -c "$COMMUNITY" "$MIKROTIK_IP" 1.3.6.1.4.1.14988.1.1.3 2>/dev/null | head -20

echo ""
echo "=== Temperature (device ini: .13.0 → 47.7°C) ==="
snmpget -v 2c -c "$COMMUNITY" "$MIKROTIK_IP" 1.3.6.1.4.1.14988.1.1.3.13.0 2>/dev/null || echo "OID not available"

echo ""
echo "=== Voltage (device ini: .8.0 → 23.6V) ==="
snmpget -v 2c -c "$COMMUNITY" "$MIKROTIK_IP" 1.3.6.1.4.1.14988.1.1.3.8.0 2>/dev/null || echo "OID not available"

echo ""
echo "=== Health Table (voltage, psu1-voltage, dll) ==="
snmpwalk -v 2c -c "$COMMUNITY" "$MIKROTIK_IP" 1.3.6.1.4.1.14988.1.1.3.100 2>/dev/null | head -20

echo ""
echo "=== Queue Tree ==="
snmpwalk -v 2c -c "$COMMUNITY" "$MIKROTIK_IP" 1.3.6.1.4.1.14988.1.1.2.2.1 2>/dev/null | head -20

echo ""
echo "=== Interfaces (ifName) ==="
snmpwalk -v 2c -c "$COMMUNITY" "$MIKROTIK_IP" 1.3.6.1.2.1.31.1.1.1.1 2>/dev/null | grep "ether1"
