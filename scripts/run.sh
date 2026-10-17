#!/usr/bin/env bash
#Starts a fresh Ganache blockchain, runs the Python test flow, then shuts Ganache down.

set -e
cd "$(dirname "$0")/.."

echo "Starting Ganache..."
ganache --deterministic > scripts/ganache.log 2>&1 &
GANACHE_PID=$!
trap 'kill $GANACHE_PID 2>/dev/null || true' EXIT

#Wait until Ganache answers requests (up to 30 seconds)
for i in $(seq 1 30); do
    if curl -s -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
        http://127.0.0.1:8545 > /dev/null; then
        echo "Ganache is ready."
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo "Ganache did not start. See scripts/ganache.log"
        exit 1
    fi
    sleep 1
done

python scripts/interact.py

echo "Done. Shutting down Ganache."