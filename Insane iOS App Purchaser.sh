#!/bin/bash

version="1.0"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

center_message_input() {
    local message="$1"
    local top_border_char="$2"
    local bottom_border_char="$3"
    local input_prompt="$4"

    # Get the terminal dimensions
    local rows=$(tput lines)
    local cols=$(tput cols)

    # Calculate the number of lines in the message
    local message_lines=$(echo "$message" | wc -l)

    # Calculate the vertical position for the message, considering the number of message lines
    local top_padding=$(( (rows - message_lines) / 2 ))
    local bottom_padding=$(( rows - message_lines - top_padding - 2 ))

    # Clear the screen
    clear

    # Print the top border
    printf '%*s\n' "$cols" '' | tr ' ' "$top_border_char"

    # Print empty lines until reaching the vertical position
    for ((i = 1; i < top_padding; i++)); do
        printf "\n"
    done
    
    # Print the message aligned to the left
    echo -e "$message"

    # Print empty lines until reaching the bottom row
    for ((i = 0; i < bottom_padding; i++)); do
        printf "\n"
    done

    # Print the bottom border
    printf '%*s\n' "$cols" '' | tr ' ' "$bottom_border_char"

    # Read user input with the provided prompt
    read -p "$input_prompt" -r -n 1 choice
    
    export choice
}

center_message_input "Insane iOS App Purchaser, $version by @disfordottie


Make sure you have ipatool installed (https://github.com/majd/ipatool)

Thanks majd for making ipatool" '#' '#' "Press Any Key To Continue: "

center_message_input "Before starting make sure you have a list of bundle id's
saved to the directory the script is currently in:
            
(\"$SCRIPT_DIR/bundleIds.txt\")

The file should be in the formt: bundle id (new line) bundle id (new line) etc.

Ensure you have authenticated ipatool (ipatool auth)
" '#' '#' "Press Any Key To Begin: "

# Define the input file
INFILE=${SCRIPT_DIR}/bundleIds.txt

# Read the input file line by line using a for loop
IFS=$'\n' # set the Internal Field Separator to newline
for LINE in $(cat "$INFILE")
do
    echo "$LINE"
    ipatool purchase -b "$LINE"
done
