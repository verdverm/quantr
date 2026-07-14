#!/bin/bash

services=(
    ssh
    dbus
    systemd-logind
    systemd-networkd
    systemd-resolved
    systemd-journald
)

show_oom() {
    printf "%-25s %8s %10s\n" "SERVICE" "PID" "OOM_ADJ"
    printf "%-25s %8s %10s\n" "-------" "---" "-------"
    for svc in "${services[@]}"; do
        pid=$(systemctl show -p MainPID --value "$svc" 2>/dev/null)
        if [[ -n "$pid" && "$pid" != "0" ]]; then
            oom=$(ps -p "$pid" -o oomadj= 2>/dev/null)
            printf "%-25s %8s %10s\n" "$svc" "$pid" "${oom:--}"
        else
            printf "%-25s %8s %10s\n" "$svc" "-" "-"
        fi
    done
}

set_oom() {
    # local value=$1
    # shift
    local value=-17 # current setting to prevent killing in linux kernel
    local targets=("$@")
    for svc in "${targets[@]}"; do
        pid=$(systemctl show -p MainPID --value "$svc" 2>/dev/null)
        if [[ -n "$pid" && "$pid" != "0" ]]; then
            echo "Setting $svc (PID $pid) to $value"
            echo "$value" | sudo tee "/proc/$pid/oom_score_adj" > /dev/null
        else
            echo "Service $svc not found or not running"
        fi
    done
    echo "Done. Current state:"
    show_oom
}

if [[ $# -eq 0 ]]; then
    show_oom
else
    value=$1
    shift
    set_oom "$value" "$@"
fi
