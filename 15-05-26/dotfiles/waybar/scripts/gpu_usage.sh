#!/bin/bash

# Function to check NVIDIA (Umbreon dGPU)
get_nvidia() {
    if [[ -e /dev/nvidiactl ]] || lsmod | grep -q "^nvidia"; then
        if command -v nvidia-smi &> /dev/null; then
            usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)
            if [[ "$usage" =~ ^[0-9]+$ ]]; then
                echo "$usage"
                return 0
            fi
        fi
    fi
    return 1
}

# Function to check AMD (Sylveon / Umbreon iGPU / Flareon)
get_amd() {
    for card in /sys/class/drm/card*/device/gpu_busy_percent; do
        if [[ -f "$card" ]]; then
            usage=$(cat "$card" 2>/dev/null)
            if [[ "$usage" =~ ^[0-9]+$ ]]; then
                echo "$usage"
                return 0
            fi
        fi
    done
    return 1
}

# Function to check Intel (Espeon)
get_intel() {
    if [[ -d /sys/class/drm/card0/device/intel-gpu-core ]] || lsmod | grep -q "^i915\|^xe"; then
        echo "0"
        return 0
    fi
    return 1
}

if get_nvidia; then
    exit 0
elif get_amd; then
    exit 0
elif get_intel; then
    exit 0
else
    echo "0"
fi
