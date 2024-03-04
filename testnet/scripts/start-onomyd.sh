#!/bin/bash
set -eu

echo "Starting onomy node"

# Ensure the open file limit is sufficient
if [ "$(ulimit -n)" -lt 65535 ]; then
    echo "Fail ulimit: $(ulimit -n) < 65535"
    exit 1
fi

# Dynamically construct the path to the onomyd executable
ONOMYD_PATH="$HOME/.onomy/cosmovisor/genesis/bin/onomyd"

# Check if the onomyd executable exists at the constructed path
if [ ! -f "$ONOMYD_PATH" ]; then
    echo "onomyd executable not found at $ONOMYD_PATH."
    exit 1
fi

# Start the onomyd using the dynamically found path
$ONOMYD_PATH start
