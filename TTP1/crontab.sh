#!/bin/bash

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 /path/to/binary [optional arguments]"
    echo "Example: $0 /usr/local/bin/myapp --config /etc/myapp.conf"
    exit 1
fi

BINARY_PATH="$1"
shift
ARGS="$@"

# Check if binary exists and is executable
if [ ! -f "$BINARY_PATH" ]; then
    echo "Error: Binary not found at $BINARY_PATH"
    exit 1
fi

if [ ! -x "$BINARY_PATH" ]; then
    echo "Error: $BINARY_PATH is not executable"
    exit 1
fi

# Construct the cron entry
if [ -n "$ARGS" ]; then
    CRON_ENTRY="@reboot sleep 30 && $BINARY_PATH $ARGS"
else
    CRON_ENTRY="@reboot sleep 30 && $BINARY_PATH"
fi

# Check if entry already exists
if crontab -l 2>/dev/null | grep -F "$CRON_ENTRY" > /dev/null; then
    echo "Entry already exists in crontab:"
    echo "$CRON_ENTRY"
    exit 0
fi

# Add to crontab
(crontab -l 2>/dev/null || true; echo "$CRON_ENTRY") | crontab -

echo "Successfully added to crontab:"
echo "$CRON_ENTRY"
echo ""
echo "Current crontab:"
crontab -l

