#!/bin/bash

version="1.1"

red=`tput setaf 1`
green=`tput setaf 2`
lightgreen='\033[1;32m'
cyan=`tput setaf 6`
none=`tput sgr0`
yellow='\033[1;33m'
purple='\033[1;35m'
lightred='\033[1;31m'
bold=$(tput bold)

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

center_message_input() {
    local message="$1"
    local top_border_char="$2"
    local bottom_border_char="$3"
    local input_prompt="$4"
    local title="$5"

    # Get the terminal dimensions
    local rows=$(tput lines)
    local cols=$(tput cols)

    # Calculate the number of lines in the message
    local message_lines=$(echo "$message" | wc -l)
    
    # Calculate the vertical position for the message, considering the number of message lines
    local top_padding=$(( (rows - message_lines) / 2 ))
    local bottom_padding=$(( rows - message_lines - top_padding - 2 ))

    # Clear the screen
    #clear
    echo -e "\n"

    # Calculate the padding for the title
    local title_length=${#title}
    local left_padding=$(( (cols - title_length) / 2 ))
    local right_padding=$(( cols - title_length - left_padding ))

    # Print the top border with the title centered
    printf "%*s" "$left_padding" | tr ' ' "$top_border_char"
    printf "%s" "$title"
    printf "%*s\n" "$right_padding" | tr ' ' "$top_border_char"

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


main_menu() {
    center_message_input "${bold}Insane iOS App Purchaser, $version by ${cyan}@disfordottie${none}


This script purchases apps in bulk using a list of Bundle ID's.

1. Use my own list

2. Browse existing lists" '#' '#' "Choice: " " Main Menu "

    while [[ "$choice" != "1" && "$choice" != "2" ]]; do
        center_message_input "${bold}Insane iOS App Purchaser, $version by ${cyan}@disfordottie${none}


This script purchases apps in bulk using a list of Bundle ID's.

1. Use my own list

2. Browse existing lists

${lightred}${bold}\"$choice\" is not a valid option${none}" '#' '#' "Choice: " " Main Menu "
    done
    local list_option=$choice

    center_message_input "${yellow}${bold}Make sure you have ipatool installed (https://github.com/majd/ipatool)${none}


Ensure you have authenticated it using

(ipatool auth login -e <your appleid>)


Thanks majd for making ipatool
" '#' '#' "Press Any Key To Continue: " " Prerequisites "

    if [ "$list_option" == "1" ]; then
        manual
    else
        existing
    fi

}

manual() {

    center_message_input "Before starting make sure you have a list of Bundle ID's
saved to the directory the script is currently in:

${purple}${bold}(\"$SCRIPT_DIR/bundleIds.txt\")${none}

The file should be in the formt: bundle id (new line) bundle id (new line) etc.

" '#' '#' "Press Any Key To Start: " " Own List "
    
    if [ -e "$SCRIPT_DIR/bundleIds.txt" ]; then
        pruchase "bundleIds"
    else
        center_message_input "${lightred}${bold}bundleIds.txt file not found.${none}" '#' '#' "Press Any Key To Return To Main Menu: " " Own List "
        main_menu
    fi
}

existing() {

    local files_list="${bold}Below are all available lists.${none}
"

    # Fetch the directory contents
    local response=$(curl -s "https://api.github.com/repos/disfordottie/insaneAppPurchaser/contents/Lists?ref=main")
    
    local file_count=0
    
    # Display files with correct handling for spaces
    local index=1
    while IFS= read -r file; do
        #echo "$index. ${file}"
  
        #files_list="$files_list\n$index. ${file}"
  
        files_list=$(cat <<EOF
$files_list
${bold}$index.${none} ${purple}${file}${none}
EOF
)

        ((index++))
        ((file_count++))
    done < <(echo "$response" | jq -r '.[] | select(.type == "file") | .name' | sed 's/\.[^.]*$//')
    
    choice=-1
    if [ "$file_count" -eq 0 ]; then
        #no lists
        center_message_input "${lightred}${bold}No lists where found on the server.${none}

Check your internet connection and try again." '#' '#' "Press Any Key To Return To Main Menu: " " Existing List "
        main_menu
        return
    else
        #lists
        center_message_input "$files_list" '#' '#' "List to use: " " Existing List "
        while ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "$file_count" ]; do
        #Choice is greater than $value and greater than 0.
        center_message_input "$files_list
        
${lightred}${bold}Choose a number from 1 to $file_count${none}" '#' '#' "List to use: " " Existing List "
        done
    fi

    # Get the download URL of the selected file
    local url=$(echo "$response" | jq -r ".[$((choice-1))] | select(.type == \"file\") | .download_url")
    
    local file_name=$(basename "$url" | sed 's/\.[^.]*$//')

    # Download the file as appIds.txt
    curl -o "$SCRIPT_DIR/existingList.txt" "$url"

    file_name=$(echo "$file_name" | sed 's/%20/ /g')
    file_name=$(echo "$file_name" | sed 's/%26/\&/g')
    echo "File downloaded as 'existingList.txt'. (Original: $file_name)"
    
    local line_count=$(awk 'END {print NR}' "$SCRIPT_DIR/existingList.txt")
    center_message_input "${purple}${bold}Ready to start.${none}
    
${bold}The list \"$file_name\" contains $line_count apps.${none}" '#' '#' "Press Any Key To Start: " " Existing List "
    
    pruchase "existingList"
}

pruchase() {

    local success_count=0
    local license_exists_count=0
    local json_unmarshal_count=0
    local no_host_count=0
    local app_not_found_count=0
    local other_error_count=0
    
    local file_name="$1"
    # Define the input file
    local INFILE=${SCRIPT_DIR}/$file_name.txt
    
    echo "$INFILE"

    local line_number=1

    local rows=$(tput lines)
    for ((i=1; i<=rows; i++)); do
        echo -e "\n"
    done

    # Read the input file line by line using a for loop
    local IFS=$'\n' # set the Internal Field Separator to newline
    for LINE in $(cat "$INFILE")
    do
        echo "Processing line number: $line_number"
        echo "$LINE"
        
        #ipatool purchase -b "$LINE"
        local last_line=$(ipatool purchase -b "$LINE" 2>&1 | tail -n 1)
        echo "$last_line"

        # Check the last line for the specific phrases and tally their occurrences
        if [[ "$last_line" =~ "success" ]] && [[ "$last_line" =~ "true" ]] && [[ "$last_line" =~ "INF" ]]; then
            ((success_count++))
        elif [[ "$last_line" =~ "license already exists" ]]; then
            ((license_exists_count++))
        elif [[ "$last_line" =~ "failed to unmarshal json" ]]; then
            ((json_unmarshal_count++))
        elif [[ "$last_line" =~ "no such host" ]]; then
            ((no_host_count++))
        elif [[ "$last_line" =~ "app not found" ]]; then
            ((app_not_found_count++))
        else
            ((other_error_count++))
        fi
        
        ((line_number++))
    done
    
    ((line_number--))
    
    # Print the tally results
    echo "success: $success_count"
    echo "license already exists: $license_exists_count"
    echo "failed to unmarshal json: $json_unmarshal_count"
    echo "no such host: $no_host_count"
    echo "app not found: $app_not_found_count"
    echo "other errors: $other_error_count"
    
    local status_message=""

    #success
    if [ "$success_count" -eq 1 ]; then
        status_message=$(cat <<EOF
$status_message
${lightgreen}1 app was purchased successfully.${none}
EOF
)
    elif [ "$success_count" -gt 1 ]; then
        status_message=$(cat <<EOF
$status_message
${lightgreen}$success_count apps were purchased successfully.${none}
EOF
)
    fi
    
    #errors title
    if (( success_count > 0 && (license_exists_count > 0 || json_unmarshal_count > 0 || no_host_count > 0 || app_not_found_count > 0 || other_error_count > 0) )); then
        status_message=$(cat <<EOF
$status_message
 
EOF
)
#${red}${bold}Errors:${none}
    fi
    
    #already purchased
    if [ "$license_exists_count" -eq 1 ]; then
        status_message=$(cat <<EOF
$status_message
${red}${bold}1 app had already been purchased.${none}
EOF
)
    elif [ "$license_exists_count" -gt 1 ]; then
        status_message=$(cat <<EOF
$status_message
${red}${bold}$license_exists_count apps had already been purchased.${none}
EOF
)
    fi
    
    #weird error
    if [ "$json_unmarshal_count" -eq 1 ]; then
        status_message=$(cat <<EOF
$status_message
${red}${bold}1 app couldnt be purchased due to an invalid charecter.${none}
EOF
)
    elif [ "$json_unmarshal_count" -gt 1 ]; then
        status_message=$(cat <<EOF
$status_message
${red}${bold}$json_unmarshal_count apps couldnt be purchased due to an invalid charecter.${none}
EOF
)
    fi
    
    #no wifi
    if [ "$no_host_count" -eq 1 ]; then
        status_message=$(cat <<EOF
$status_message
${red}${bold}1 app couldnt be purchased because Apples servers couldnt be reached.${none}
EOF
)
    elif [ "$no_host_count" -gt 1 ]; then
        status_message=$(cat <<EOF
$status_message
${red}${bold}$no_host_count apps couldnt be purchased because Apples servers couldnt be reached.${none}
EOF
)
    fi
    
    #app not found
    if [ "$app_not_found_count" -eq 1 ]; then
        status_message=$(cat <<EOF
$status_message
${red}${bold}1 app couldnt be found in your country / region.${none}
EOF
)
    elif [ "$app_not_found_count" -gt 1 ]; then
        status_message=$(cat <<EOF
$status_message
${red}${bold}$app_not_found_count apps couldnt be found in your country / region.${none}
EOF
)
    fi
    
    #other erros
    if [ "$other_error_count" -eq 1 ]; then
        status_message=$(cat <<EOF
$status_message
${red}${bold}1 app couldnt be pruchased because of a rare error.${none}
EOF
)
    elif [ "$other_error_count" -gt 1 ]; then
        status_message=$(cat <<EOF
$status_message
${red}${bold}$other_error_count apps couldnt be pruchased because of a rare error.${none}
EOF
)
    fi
    
    status_message=$(cat <<EOF
${purple}${bold}$line_number apps total were processed.${none}
$status_message
EOF
)

    if [[ "$file_name" == "existingList" ]]; then
        rm ${SCRIPT_DIR}/existingList.txt
    fi
    
    if [ "$line_number" -eq 0 ]; then
        center_message_input "${lightred}${bold}The list was empty, hence no apps where purchased.${none}" '#' '#' "Press Any Key To Return To Main Menu: " " Process Complete "
    else
        center_message_input "$status_message" '#' '#' "Press Any Key To Return To Main Menu: " " Process Complete "
    fi
    
    main_menu
    
}

main_menu
