# WireGuard macOS LaunchDaemon Installation Guide

## Overview
This guide explains how to set up WireGuard to automatically start when your MacBook boots, using macOS's launchd system. The configuration uses the CLI-based WireGuard tools rather than a GUI application.

## Prerequisites

### 1. Verify WireGuard is Installed
```bash
which wg-quick
which wg
```

Expected output:
```
/usr/local/bin/wg-quick
/usr/local/bin/wg
```

If not installed, install via Homebrew:
```bash
brew install wireguard-tools
```

### 2. Verify WireGuard Configuration Exists
Your WireGuard configuration file should exist at:
```bash
ls -la /etc/wireguard/wg0.conf
```

If the config is in a different location, note the path for later steps.

### 3. Test WireGuard Manually
Before automating, verify it works:
```bash
# Start WireGuard interface
sudo wg-quick up wg0

# Check status
sudo wg show

# Test connectivity
ping 10.0.0.1

# Stop (for testing)
sudo wg-quick down wg0
```

---

## Installation Steps

### Step 1: Verify LaunchDaemon Plist Configuration

Check that `/home/empire/gateway-mgmt/wireguard/com.wireguard.plist` is configured correctly:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.wireguard.daemon</string>
    
    <key>Program</key>
    <string>/usr/local/bin/wg-quick</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/wg-quick</string>
        <string>up</string>
        <string>wg0</string>
    </array>
    
    <key>RunAtLoad</key>
    <true/>
    
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
    
    <key>StandardOutPath</key>
    <string>/var/log/wireguard.log</string>
    
    <key>StandardErrorPath</key>
    <string>/var/log/wireguard-error.log</string>
    
    <key>UserName</key>
    <string>root</string>
</dict>
</plist>
```

**Configuration Notes:**
- `wg0` - Change this if your interface is named differently (e.g., `wg1`)
- If your config is at a non-standard location, adjust the `ProgramArguments` or create a symlink

### Step 2: Copy Plist to LaunchDaemons Directory

```bash
# Copy the plist file to the system LaunchDaemons directory
sudo cp /home/empire/gateway-mgmt/wireguard/com.wireguard.plist /Library/LaunchDaemons/com.wireguard.daemon.plist

# Verify it was copied
ls -la /Library/LaunchDaemons/com.wireguard.daemon.plist
```

### Step 3: Set Correct Permissions

```bash
# Set file permissions (must be readable by root)
sudo chmod 644 /Library/LaunchDaemons/com.wireguard.daemon.plist

# Verify permissions
ls -la /Library/LaunchDaemons/com.wireguard.daemon.plist
```

Expected output:
```
-rw-r--r--  1 root  wheel  com.wireguard.daemon.plist
```

### Step 4: Load the LaunchDaemon

```bash
# Load the service (this also starts it immediately)
sudo launchctl load /Library/LaunchDaemons/com.wireguard.daemon.plist
```

### Step 5: Verify Installation

```bash
# Check if the service is loaded
sudo launchctl list | grep wireguard

# Check if WireGuard interface is up
ifconfig wg0

# View detailed status
sudo wg show
```

Expected output for `launchctl list`:
```
-	0	com.wireguard.daemon
```

Expected output for `ifconfig wg0`:
```
wg0: flags=... mtu 1420
	inet 10.0.0.2 netmask 0xffffff00 broadcast 10.0.0.255
	...
```

---

## Verification & Testing

### Test 1: Check if Service Started
```bash
sudo launchctl list com.wireguard.daemon
```

You should see a successful status (PID > 0).

### Test 2: Check Logs
```bash
# View startup logs
sudo tail -n 50 /var/log/wireguard.log
sudo tail -n 50 /var/log/wireguard-error.log
```

### Test 3: Connectivity Test
```bash
# Test connection to your VPN gateway
ping -c 3 10.0.0.1

# Test connection through VPN
curl -s http://10.0.0.1:9090/api/v1/status/config | jq .
```

### Test 4: Simulate Reboot (Optional)
```bash
# Unload and reload to simulate boot behavior
sudo launchctl unload /Library/LaunchDaemons/com.wireguard.daemon.plist
sudo launchctl load /Library/LaunchDaemons/com.wireguard.daemon.plist

# Verify it reconnected
sleep 2
ifconfig wg0
```

---

## Troubleshooting

### WireGuard Interface Not Coming Up

**Check logs:**
```bash
sudo tail -f /var/log/wireguard-error.log
```

**Common issues:**
- Config file not found or incorrect path
- `wg-quick` binary not in expected location
- Network interface already in use

**Fix:**
```bash
# Manually test the command
sudo /usr/local/bin/wg-quick up wg0

# If it fails, check configuration
cat /etc/wireguard/wg0.conf
```

### LaunchDaemon Not Loading

**Verify plist syntax:**
```bash
plutil -lint /Library/LaunchDaemons/com.wireguard.daemon.plist
```

Output should say: `OK`

**Reload launchd:**
```bash
sudo launchctl stop com.wireguard.daemon
sudo launchctl start com.wireguard.daemon
```

### Permission Denied Errors

**Ensure root ownership and permissions:**
```bash
sudo ls -la /Library/LaunchDaemons/com.wireguard.daemon.plist
sudo chmod 644 /Library/LaunchDaemons/com.wireguard.daemon.plist
```

### WireGuard Connects Then Disconnects

**Set `KeepAlive` to restart on failures:**
```bash
# Already in the plist, but check:
sudo launchctl list com.wireguard.daemon
```

If it keeps restarting, check:
- Network connectivity issues
- VPN credential validity
- Firewall blocking WireGuard protocol (UDP 51820)

---

## Management Commands

### View Service Status
```bash
sudo launchctl list com.wireguard.daemon
```

### Start Service Manually
```bash
sudo launchctl start com.wireguard.daemon
```

### Stop Service
```bash
sudo launchctl stop com.wireguard.daemon
```

### Unload (Disable Autostart)
```bash
sudo launchctl unload /Library/LaunchDaemons/com.wireguard.daemon.plist
```

### Reload (After Config Changes)
```bash
sudo launchctl unload /Library/LaunchDaemons/com.wireguard.daemon.plist
sudo launchctl load /Library/LaunchDaemons/com.wireguard.daemon.plist
```

### View Real-Time Logs
```bash
sudo tail -f /var/log/wireguard.log
sudo tail -f /var/log/wireguard-error.log
```

---

## Configuration Customization

### Change WireGuard Interface Name

If your interface is `wg1` instead of `wg0`, edit the plist:

```bash
sudo nano /Library/LaunchDaemons/com.wireguard.daemon.plist
```

Find this section and change `wg0` to your interface name:
```xml
<key>ProgramArguments</key>
<array>
    <string>/usr/local/bin/wg-quick</string>
    <string>up</string>
    <string>wg0</string>  <!-- Change this -->
</array>
```

Then reload:
```bash
sudo launchctl unload /Library/LaunchDaemons/com.wireguard.daemon.plist
sudo launchctl load /Library/LaunchDaemons/com.wireguard.daemon.plist
```

### Change Config File Location

If your WireGuard config is elsewhere, create a symlink:
```bash
sudo ln -s /path/to/your/wg0.conf /etc/wireguard/wg0.conf
```

Or modify the plist to use the full path:
```xml
<string>wg0</string>  <!-- Change to: /path/to/config/wg0.conf -->
```

### Adjust Log Locations

Edit log paths in the plist if needed:
```xml
<key>StandardOutPath</key>
<string>/var/log/wireguard.log</string>

<key>StandardErrorPath</key>
<string>/var/log/wireguard-error.log</string>
```

Ensure the log directory exists and is writable by root:
```bash
sudo touch /var/log/wireguard.log
sudo touch /var/log/wireguard-error.log
sudo chmod 644 /var/log/wireguard*.log
```

---

## Next Steps

After successful installation:

1. **Test on reboot**: Restart your Mac and verify WireGuard connects automatically
2. **Monitor logs**: Check logs periodically for any issues
3. **Integration**: Update `.github/copilot-instructions.md` to document this setup
4. **Backup**: Keep the plist in your `gateway-mgmt` repository for future reference

---

## Additional Resources

- [macOS LaunchDaemons Documentation](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchDaemons.html)
- [WireGuard Installation](https://www.wireguard.com/install/)
- [wg-quick Manual](https://man.archlinux.org/man/wg-quick.8.en)

