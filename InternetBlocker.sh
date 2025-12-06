#!/bin/bash


# InternetBlocker.sh
# Author: Makayla Baker
# Purpose: Block all HTTP/HTTPS traffic except for IT users/employes and a local web server

# Step 0: Clear existing OUTPUT rules to prevent conflict
sudo iptables -F OUTPUT

# Step 1: Retrieve IT users
IT_USERS=$(getent group IT | awk -F: '{print $4}' | tr ',' ' ')

# Initialize counter for number of IT users
count=0

# Check if IT_USERS is empty
if [ -z "$IT_USERS" ]; then
    echo "Warning: No users found in the IT group!"
fi

# Step 2: Allow HTTP & HTTPS for IT users
for user in $IT_USERS; do
    # Check if user exists on system
    if id "$user" &>/dev/null; then
        # Allow HTTPS (port 443)
        sudo iptables -A OUTPUT -p tcp --dport 443 -m owner --uid-owner "$user" -j ACCEPT
        # Allow HTTP (port 80)
        sudo iptables -A OUTPUT -p tcp --dport 80 -m owner --uid-owner "$user" -j ACCEPT
        ((count++))
    fi
done


# Step 3: Allow local web server access
sudo iptables -A OUTPUT -p tcp --dport 443 -d 192.168.2.3 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 80 -d 192.168.2.3 -j ACCEPT


# Step 4: Block special access ports
sudo iptables -t filter -A OUTPUT -p tcp --dport 8003 -j DROP
sudo iptables -t filter -A OUTPUT -p tcp --dport 1979 -j DROP


# Step 5: Block all other HTTP/HTTPS traffic
sudo iptables -A OUTPUT -p tcp --dport 443 -j DROP
sudo iptables -A OUTPUT -p tcp --dport 80 -j DROP

-
# Step 6: Final message
echo "Internet access granted to $count IT user(s)."

exit 0
