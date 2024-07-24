#!/bin/bash

LOG_DIR="/tmp"
INFO_LOG="${LOG_DIR}/nginx_info.log"
ERROR_LOG="${LOG_DIR}/nginx_error.log"
SERVER_INFO_FILE="${LOG_DIR}/server_info.txt"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$INFO_LOG"
}

# Collect server information
collect_server_info() {
    {
        echo "=== Server Information ==="
        echo "Date: $(date)"
        echo "Hostname: $(hostname)"
        echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
        echo "Kernel: $(uname -r)"
        echo "CPU: $(grep 'model name' /proc/cpuinfo | uniq | cut -d':' -f2 | xargs)"
        echo "Memory: $(free -h | awk '/^Mem:/ {print $2}')"
        echo "Disk Usage: $(df -h / | awk 'NR==2 {print $5}')"
        echo ""
        echo "=== Nginx Information ==="
        echo "Nginx Version: $(nginx -v 2>&1)"
        echo "Nginx Configuration:"
        echo "---"
        cat /etc/nginx/nginx.conf
        echo "---"
        echo ""
        echo "=== Process Information ==="
        echo "Running Processes:"
        ps aux
        echo ""
        echo "=== Network Information ==="
        echo "Network Interfaces:"
        ip addr
        echo ""
        echo "Network Connections:"
        netstat -tuln
    } > "$SERVER_INFO_FILE"
}

# Main loop
while true; do
    # Collect server information
    collect_server_info
    log_message "Server information collected"

    # Check Nginx status
    if pgrep nginx > /dev/null
    then
        log_message "Nginx is running"
    else
        log_message "ERROR: Nginx is not running" >> "$ERROR_LOG"
    fi

    # Collect Nginx access logs (last 100 lines)
    tail -n 100 /var/log/nginx/access.log >> "$INFO_LOG"

    # Collect Nginx error logs (last 100 lines)
    tail -n 100 /var/log/nginx/error.log >> "$ERROR_LOG"

    # Sleep for 5 minutes
    sleep 300
done