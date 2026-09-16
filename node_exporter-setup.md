# Node Exporter Setup Guide

## Prerequisites
- node_exporter binary copied to `/usr/local/bin/node_exporter`
- Prometheus service already running

## Step 1: Create Dedicated User

```bash
sudo useradd -r -s /bin/false node_exporter
```

This creates a system user with no shell access for security.

## Step 2: Create Systemd Service File

Create `/etc/systemd/system/node_exporter.service`:

```ini
[Unit]
Description=Node Exporter
Documentation=https://github.com/prometheus/node_exporter
After=prometheus.service
Wants=prometheus.service

[Service]
Type=simple
User=node_exporter
ExecStart=/usr/local/bin/node_exporter --web.listen-address=0.0.0.0:9100
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

**Key settings:**
- `After=prometheus.service` - Starts after Prometheus is running
- `Wants=prometheus.service` - Attempts to start Prometheus if not running
- `--web.listen-address=0.0.0.0:9100` - Listens on all interfaces on port 9100
- `Restart=on-failure` - Automatically restarts if it crashes
- `RestartSec=5s` - Waits 5 seconds before restarting

## Step 3: Deploy the Service

```bash
# Copy the service file
sudo tee /etc/systemd/system/node_exporter.service > /dev/null << 'EOF'
[Unit]
Description=Node Exporter
Documentation=https://github.com/prometheus/node_exporter
After=prometheus.service
Wants=prometheus.service

[Service]
Type=simple
User=node_exporter
ExecStart=/usr/local/bin/node_exporter --web.listen-address=0.0.0.0:9100
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon
sudo systemctl daemon-reload

# Enable service to start on boot
sudo systemctl enable node_exporter

# Start the service
sudo systemctl start node_exporter

# Verify it's running
sudo systemctl status node_exporter
```

## Step 4: Verify Functionality

```bash
# Check the service status
systemctl status node_exporter

# Check if it's listening on port 9100
ss -tulpn | grep 9100

# Test metrics endpoint
curl http://localhost:9100/metrics | head -20

# Check Prometheus targets
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job, instance: .labels.instance, health}'
```

## Step 5: Configure Prometheus to Scrape Node Exporter

Update `/etc/prometheus/prometheus.yml`:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: node_exporter
    static_configs:
      - targets: ['localhost:9100', '10.0.0.1:9100']
```

Reload Prometheus:
```bash
sudo systemctl reload prometheus
```

## Troubleshooting

**Service fails to start:**
```bash
sudo systemctl status node_exporter
sudo journalctl -u node_exporter -n 50
```

**Port already in use:**
```bash
sudo ss -tulpn | grep 9100
# Kill the process if needed: sudo kill -9 <PID>
```

**Prometheus can't reach node_exporter:**
- Verify firewall rules: `sudo ufw status`
- Add rule if needed: `sudo ufw allow from 10.0.0.2 to any port 9100 proto tcp`
- Check network connectivity: `ping 10.0.0.1`

## Common Commands

```bash
# Start the service
sudo systemctl start node_exporter

# Stop the service
sudo systemctl stop node_exporter

# Restart the service
sudo systemctl restart node_exporter

# View logs
sudo journalctl -u node_exporter -f

# Disable auto-start on boot
sudo systemctl disable node_exporter
```
