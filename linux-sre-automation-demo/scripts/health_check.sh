#!/usr/bin/env bash
set -euo pipefail
JSON=false; [[ "${1:-}" == "-j" ]] && JSON=true
HOST="$(hostname)"; TIME="$(date -Iseconds)"
UPTIME_STR="$(uptime -p | sed 's/^up //')"
LOADAVG="$(cut -d' ' -f1-3 /proc/loadavg)"
CPU_CORES="$(nproc)"
MEM_TOTAL_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEM_AVAIL_KB=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
DISK_SUMMARY="$(df -h --output=source,size,used,avail,pcent,target -x tmpfs -x devtmpfs | tail -n +2)"
TOP_PROCS="$(ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -n 5)"
FAILED_SERVICES="$(systemctl --failed --no-legend || true)"
GW=$(ip route | awk '/default/ {print $3; exit}')
DNS=$(awk '/^nameserver/ {print $2}' /etc/resolv.conf | paste -sd, -)
print_kv(){ $JSON && printf '%s="%s"\n' "$1" "$(sed 's/"/\\"/g'<<<"$2")" || printf "%-22s %s\n" "$1:" "$2"; }
print_section(){ $JSON || { echo; echo "== $1 =="; }; }
print_kv "host" "$HOST"; print_kv "time" "$TIME"; print_kv "uptime" "$UPTIME_STR"
print_kv "loadavg_1m_5m_15m" "$LOADAVG"; print_kv "cpu_cores" "$CPU_CORES"
print_kv "mem_total_kb" "$MEM_TOTAL_KB"; print_kv "mem_available_kb" "$MEM_AVAIL_KB"
print_section "Disk usage"; $JSON || echo "$DISK_SUMMARY"
print_section "Top CPU processes"; $JSON || echo "$TOP_PROCS"
print_section "Failed systemd services"; [[ -n "$FAILED_SERVICES" ]] && { $JSON || echo "$FAILED_SERVICES"; } || { $JSON || echo "None"; }
print_kv "default_gateway" "${GW:-unknown}"; print_kv "dns_servers" "${DNS:-unknown}"
if [[ -n "${GW:-}" ]]; then ping -c1 -W1 "$GW" >/dev/null 2>&1 && print_kv "gateway_ping" "ok" || print_kv "gateway_ping" "failed"; fi
