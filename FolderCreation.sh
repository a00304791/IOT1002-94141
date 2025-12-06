#!/bin/bash
# Makayla Baker - A00304791
# FolderCreation.sh
# IOT1025 - Semester Long Assignment 4
# Creates EmployeeData folder structure with correct permissions, ownership, and summary message.

# Base directory
BASE="/EmployeeData"

# Folder list
FOLDERS=("HR" "IT" "Finance" "Executive" "Administrative" "CallCentre")

# Sensitive folders
SENSITIVE=("HR" "Executive")

# Counter for created folders
COUNT=0

echo "Creating folder structure under $BASE..."

# Create base directory if it doesn't already exist
if [ ! -d "$BASE" ]; then
    mkdir "$BASE"
fi

# Loop through folders
for DEPT in "${FOLDERS[@]}"; do
    
    # Create folder path
    DIR="$BASE/$DEPT"

    # Create folder
    mkdir -p "$DIR"
    ((COUNT++))

    # Ensure department group exists
    # (This prevents errors if the group was not previously created)
    if ! getent group "$DEPT" > /dev/null; then
        groupadd "$DEPT"
    fi

    # Set both user owner *and* group owner
    chown root:"$DEPT" "$DIR"

    # Permissions section
    if [[ " ${SENSITIVE[@]} " =~ " $DEPT " ]]; then
        # Sensitive folders: rwx rw_ ___  =  770
        chmod -R 770 "$DIR"
    else
        # Normal folders: rwx rw_ r__  =  774
        chmod -R 774 "$DIR"
    fi

done

echo "------------------------------------------------------"
echo "$COUNT folders were successfully created under /EmployeeData"
echo "Script has completed!"
echo "------------------------------------------------------"
