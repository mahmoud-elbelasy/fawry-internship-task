#!/bin/bash

# Initialize options
SHOW_LINE_NUMBERS=0
INVERT_MATCH=0

# Parse options (-n, -v, -nv, -vn)
while [[ "$1" == -* ]]; do
    case "$1" in
        -n) SHOW_LINE_NUMBERS=1; shift ;;
        -v) INVERT_MATCH=1; shift ;;
        -nv|-vn) 
            SHOW_LINE_NUMBERS=1
            INVERT_MATCH=1
            shift
            ;;
        *)
            echo "Invalid option: $1" >&2
            exit 1
            ;;
    esac
done

# Validate arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 [-n] [-v] pattern filename" >&2
    exit 1
fi

PATTERN="$1"
FILENAME="$2"

# Check if file exists
if [ ! -f "$FILENAME" ]; then
    echo "Error: File '$FILENAME' not found" >&2
    exit 1
fi

# Convert pattern to lowercase for case-insensitive comparison
LOWERCASE_PATTERN=$(echo "$PATTERN" | tr '[:upper:]' '[:lower:]')

LINE_NUMBER=0
while IFS= read -r LINE; do
    ((LINE_NUMBER++))
    
    # Convert line to lowercase and check for substring match
    LOWERCASE_LINE=$(echo "$LINE" | tr '[:upper:]' '[:lower:]')
    if [[ "$LOWERCASE_LINE" == *"$LOWERCASE_PATTERN"* ]]; then
        MATCHED=1
    else
        MATCHED=0
    fi
    
    # Handle inverted match (-v)
    if [ $INVERT_MATCH -eq 1 ]; then
        MATCHED=$((1 - MATCHED))
    fi
    
    # Print if matched
    if [ $MATCHED -eq 1 ]; then
        if [ $SHOW_LINE_NUMBERS -eq 1 ]; then
            printf "%d:%s\n" "$LINE_NUMBER" "$LINE"
        else
            printf "%s\n" "$LINE"
        fi
    fi
done < "$FILENAME"
