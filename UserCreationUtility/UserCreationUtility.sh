#!/bin/bash
# UserCreationUtility.sh
# Author: Mak Baker
# Fully working version with correct counters

FILE="employees.csv"

# To track new users and groups
NEW_USERS=()
NEW_GROUPS=()

# Check if CSV file exists
if [[ ! -f "$FILE" ]]; then
    echo "Error: File $FILE not found!"
    exit 1
fi

# Read CSV line by line (skip header)
tail -n +2 "$FILE" | while IFS=',' read -r FIRST LAST DEPT; do

    # Generate username
    USERNAME=$(echo "${FIRST:0:1}${LAST:0:7}" | tr '[:upper:]' '[:lower:]')

    # Check if group exists 
    if ! getent group "$DEPT" >/dev/null; then
        groupadd "$DEPT"
        echo "Created new group: $DEPT"
        NEW_GROUPS+=("$DEPT")   # Track new group
    else
        echo "Group '$DEPT' already exists."
    fi

    # Check if user exists 
    if id "$USERNAME" &>/dev/null; then
        echo "Error: User '$USERNAME' already exists. Skipping..."
    else
        useradd -m -g "$DEPT" "$USERNAME"
        if [[ $? -eq 0 ]]; then
            echo "Added new user: $USERNAME (Group: $DEPT)"
            NEW_USERS+=("$USERNAME")  # Track new user
        else
            echo "Error creating user: $USERNAME"
        fi
    fi

done

# Output summary using lengths of arrays
echo "-------------------------------------"
echo "Summary:"
echo "New users added: ${#NEW_USERS[@]}"
echo "New groups created: ${#NEW_GROUPS[@]}"
echo "-------------------------------------"

