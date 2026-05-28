#!/bin/bash
# Generate an SSH key pair for root and install it
# Requires: root

KEY_PATH="/root/.ssh/id_rsa"
AUTH_KEYS="/root/.ssh/authorized_keys"

# Create .ssh directory if it doesn't exist
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Generate the key pair
ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N "" -C "root@$(hostname)"

# Install the public key into authorized_keys
cat "${KEY_PATH}.pub" >> "$AUTH_KEYS"
chmod 600 "$AUTH_KEYS"

echo ""
echo "[+] Key pair generated at $KEY_PATH"
echo "[+] Public key installed to $AUTH_KEYS"
echo ""
echo "=== Public Key ==="
cat "${KEY_PATH}.pub"
