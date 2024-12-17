#!/usr/bin/env bash
set -e

WG_CONFIG="${WG_CONFIG:-wg0.conf}"

# If wg0 already exists, bring it down first
if ip link show wg0 &>/dev/null; then
    echo "wg0 already exists. Bringing it down..."
    wg-quick down /etc/wireguard/$WG_CONFIG || true
fi

echo "Starting WireGuard with config: $WG_CONFIG"
wg-quick up /etc/wireguard/$WG_CONFIG

/usr/sbin/danted -f /etc/dante/dante.conf -D
tail -f /dev/null
