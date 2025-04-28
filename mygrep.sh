#!/bin/bash

# Initialize options
SHOW_LINE_NUMBERS=0
INVERT_MATCH=0
SHOW_HELP=0

# Function to display help
display_help() {
    echo "Usage: $0 [OPTIONS] PATTERN [FILE]"
    echo "Search for PATTERN in FILE (stdin if no file specified)"
    echo ""
    echo "Options:"
    echo "  -n, --line-number    show line numbers with output"
    echo "  -v, --invert-match   select non-matching lines"
    echo "  -h, --help           display this help and exit"
    echo ""
    echo "Pattern matching is case-insensitive."
    echo "Options can be combined like -nv or -vn."
}

# Parse options using getopts for better handling
while getopts ":nvh-:" opt; do
    case $opt in
        n) SHOW_LINE_NUMBERS=1 ;;
        v) INVERT_MATCH=1 ;;
        h) SHOW_HELP=1 ;;
        -) # Handle long options
            case "${OPTARG}" in
                line-number) SHOW_LINE_NUMBERS=1 ;;
                invert-match) INVERT_MATCH=1 ;;
                help) SHOW_HELP=1 ;;
                *) echo "Invalid option: --$OPTARG" >&2; exit 1 ;;
            esac ;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
    esac
done
shift $((OPTIND-1))

# Show help if requested
if [ $SHOW_HELP -eq 1 ]; then
    display_help
    exit 0
fi

# Validate arguments
if [ $# -lt 1 ]; then
    echo "Error: Missing search pattern" >&2
    display_help
    exit 1
fi

PATTERN="$1"
shift

# Set input source (file or stdin)
if [ $# -ge 1 ]; then
    FILENAME="$1"
    if [ ! -f "$FILENAME" ] || [ ! -r "$FILENAME" ]; then
        echo "Error: Cannot read file '$FILENAME'" >&2
        exit 1
    fi
    INPUT_SOURCE="$FILENAME"
else
    INPUT_SOURCE="/dev/stdin"
fi

# Process input
LINE_NUMBER=0
while IFS= read -r LINE; do
    ((LINE_NUMBER++))
    
    # Case-insensitive matching
    if [[ "${LINE,,}" == *"${PATTERN,,}"* ]]; then
        MATCHED=1
    else
        MATCHED=0
    fi
    
    # Handle inverted match
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
done < "$INPUT_SOURCE"
