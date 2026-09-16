#!/bin/bash
# VPN Connectivity Monitor
# Created on 11/22/25 by Claude Sonnet 4, to help monitor connectivity issues. -Bucket
# Updated to fix interface naming and logging issues

LOG_FILE="/var/log/vpn-monitor.log"

# Function to log with timestamp
log_message() {
    local timestamp="[$(date '+%Y-%m-%d %H:%M:%S')]"
    echo "$timestamp $1" | tee -a "$LOG_FILE"
}

# Ensure log file exists and is writable
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

# Define WireGuard interface (check both possible names)
WG_INTERFACE="utun3"
if ! ifconfig "$WG_INTERFACE" > /dev/null 2>&1; then
    # Try alternative interface name
    WG_INTERFACE="wg0"
fi

# Check WireGuard interface
if ifconfig "$WG_INTERFACE" > /dev/null 2>&1; then
    HANDSHAKE=$(sudo wg show "$WG_INTERFACE" latest-handshakes 2>/dev/null | awk '{print $2}' | head -1)
    
    if [ -n "$HANDSHAKE" ] && [ "$HANDSHAKE" -gt 0 ]; then
        CURRENT_TIME=$(date +%s)
        TIME_DIFF=$((CURRENT_TIME - HANDSHAKE))

        if [ "$TIME_DIFF" -lt 180 ]; then  # Less than 3 minutes
            log_message "✅ WireGuard ($WG_INTERFACE): Healthy (last handshake: ${TIME_DIFF}s ago)"
        else
            log_message "⚠️  WireGuard ($WG_INTERFACE): Stale handshake (${TIME_DIFF}s ago) - restarting"
            sudo /usr/local/bin/wg-quick down "$WG_INTERFACE" 2>/dev/null
            sleep 2
            sudo /usr/local/bin/wg-quick up "$WG_INTERFACE" 2>/dev/null
            if [ $? -eq 0 ]; then
                log_message "✅ WireGuard: Reconnection successful"
            else
                log_message "❌ WireGuard: Reconnection failed"
            fi
        fi
    else
        log_message "⚠️  WireGuard ($WG_INTERFACE): No handshake data"
    fi
else
    log_message "❌ WireGuard: Interface down - attempting restart"
    sudo /usr/local/bin/wg-quick up "$WG_INTERFACE" 2>/dev/null
    sleep 2
    if ifconfig "$WG_INTERFACE" > /dev/null 2>&1; then
        log_message "✅ WireGuard: Successfully brought up interface"
    else
        log_message "❌ WireGuard: Failed to bring up interface"
    fi
fi

# Test internet connectivity (Google DNS)
if ping -c 2 -W 5 8.8.8.8 > /dev/null 2>&1; then
    log_message "✅ Internet: Connected to 8.8.8.8"
else
    log_message "❌ Internet: No connectivity to 8.8.8.8"
fi

# Test DNS resolution (macOS compatible)
if dig +short google.com @1.1.1.1 > /dev/null 2>&1 || dscacheutil -q host -a name google.com > /dev/null 2>&1; then
    log_message "✅ DNS: Resolution working"
else
    log_message "❌ DNS: Resolution failed"
fi

# Optional: Test gateway connectivity (10.0.0.1)
if ping -c 1 -W 3 10.0.0.1 > /dev/null 2>&1; then
    log_message "✅ Gateway: Reachable at 10.0.0.1"
else
    log_message "❌ Gateway: Unable to reach 10.0.0.1"
fi

log_message "---"
