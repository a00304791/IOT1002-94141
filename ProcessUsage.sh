#!/bin/bash

# ProcessUsage.sh
# Purpose: Identify top 5 CPU-consuming processes, prompt user, kill non-root processes among them, and log details.
# Author and assignment: Makayla Baker - A00304791 - Semester long assignment #2

# make a log file with today's date
LOGFILE=~/ProcessUsageReport-$(date +%Y%m%d).log
KILLED_COUNT=0

echo "--------------------------------------"
echo "   Top 5 Processes by CPU Usage   "
echo "--------------------------------------"

# Show top 5 processes by CPU usage
ps -eo pid,user,%cpu,lstart,cmd --sort=-%cpu | head -n 6

echo "--------------------------------------"
read -p "Do you want to kill safe (non-root, non-system) processes from this list? (y/n): " ANSWER

if [[ "$ANSWER" != "y" && "$ANSWER" != "Y" ]]; then
    echo "No processes were killed. Exiting safely."
    exit 0
fi

echo "Logging details to: $LOGFILE"
echo "Process Usage Report - $(date)" > "$LOGFILE"
echo "--------------------------------------" >> "$LOGFILE"

# Only check top 5 user processes (skip system daemons and roots)
ps -eo pid,user,%cpu,lstart,cmd --sort=-%cpu | tail -n +2 | head -n 5 | while read -r PID USER CPU DAY MONTH DATE TIME YEAR CMD
do
    # Skip system and root-owned processes
    if [[ "$USER" == "root" || "$PID" -lt 1000 ]]; then
        echo "Skipping PID $PID (system or root process)"
        continue
    fi

    # Skip any process related to GNOME, Xorg, or system daemons
    if echo "$CMD" | grep -Eiq "gnome|Xorg|systemd|dbus|NetworkManager|lightdm|snap"; then
        echo "Skipping PID $PID (critical system process)"
        continue
    fi

    START_TIME="$DAY $MONTH $DATE $TIME $YEAR"
    KILL_TIME=$(date "+%a %b %d %T %Y")
    DEPARTMENT=$(id -gn "$USER" 2>/dev/null)

    echo "Attempting to kill process PID $PID owned by $USER..."
    kill -9 "$PID" 2>/dev/null

    if [[ $? -eq 0 ]]; then
        ((KILLED_COUNT++))
        echo "PID $PID ($USER) killed successfully."
        {
            echo "PID: $PID"
            echo "User: $USER"
            echo "CPU: $CPU"
            echo "Command: $CMD"
            echo "Started: $START_TIME"
            echo "Killed: $KILL_TIME"
            echo "Department: ${DEPARTMENT:-UNKNOWN}"
            echo "--------------------------------------"
        } >> "$LOGFILE"
    else
        echo "Failed to kill PID $PID ($USER)"
    fi
done

echo "--------------------------------------"
echo "Total processes killed: $KILLED_COUNT"
echo "Details saved to: $LOGFILE"
echo "Done safely."
