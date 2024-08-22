#!/bin/bash

# Set refresh interval
REFRESH_INTERVAL=5

# Function to display top 10 most used applications
display_top_apps() {
  echo "Top 10 Most Used Applications:"
  ps -eo pcpu,pmem,cmd --sort=-pcpu | head -n 10
}

# Function to display network monitoring
display_network_monitoring() {
  echo "Network Monitoring:"
  echo "Concurrent connections: $(netstat -an | grep ESTABLISHED | wc -l)"
  echo "Packet drops: $(iptables -nvL | grep DROP | wc -l)"
  echo "Inbound traffic: $(ip -s link show | awk '/RX bytes/ {print $2}')"
  echo "Outbound traffic: $(ip -s link show | awk '/TX bytes/ {print $2}')"
}

# Function to display disk usage
display_disk_usage() {
  echo "Disk Usage:"
  df -h --output=source,fstype,size,used,avail,pcent,target
  echo "Partitions using more than 80% of space:"
  df -h --output=pcent,target | awk '$1 > 80 {print $2}'
}

# Function to display system load
display_system_load() {
  echo "System Load:"
  uptime
  echo "CPU usage:"
  mpstat -a | awk '$12 ~ /[0-9.]+/ {print "User: " $12 "%, System: " $13 "%, Idle: " $14 "%"}'
}

# Function to display memory usage
display_memory_usage() {
  echo "Memory Usage:"
  free -h
  echo "Swap usage:"
  swapon -s
}

# Function to display process monitoring
display_process_monitoring() {
  echo "Process Monitoring:"
  echo "Active processes: $(ps -ef | wc -l)"
  echo "Top 5 processes by CPU usage:"
  ps -eo pcpu,cmd --sort=-pcpu | head -n 5
  echo "Top 5 processes by memory usage:"
  ps -eo pmem,cmd --sort=-pmem | head -n 5
}

# Function to display service monitoring
display_service_monitoring() {
  echo "Service Monitoring:"
  for service in sshd nginx apache2 iptables; do
    echo "$service: $(systemctl is-active $service)"
  done
}

# Main function to display dashboard
display_dashboard() {
  clear
  echo "System Resource Dashboard"
  echo "------------------------"
  display_top_apps
  echo ""
  display_network_monitoring
  echo ""
  display_disk_usage
  echo ""
  display_system_load
  echo ""
  display_memory_usage
  echo ""
  display_process_monitoring
  echo ""
  display_service_monitoring
  echo ""
  echo "Press Ctrl+C to exit"
}

# Command-line switches
while getopts ":c:n:d:s:m:p:i:" opt; do
  case $opt in
    c) display_top_apps; exit 0;;
    n) display_network_monitoring; exit 0;;
    d) display_disk_usage; exit 0;;
    s) display_system_load; exit 0;;
    m) display_memory_usage; exit 0;;
    p) display_process_monitoring; exit 0;;
    i) display_service_monitoring; exit 0;;
    \?) echo "Invalid option: -$OPTARG"; exit 1;;
  esac
done

# Run dashboard in loop
while true; do
  display_dashboard
  sleep $REFRESH_INTERVAL
done