#!/bin/bash

version="1.4"

red=`tput setaf 1`
red_background='\033[7;91m'
green=`tput setaf 2`
green_background='\033[7;92m'
lightgreen='\033[1;32m'
cyan=`tput setaf 6`
cyan_background='\033[7;36m'
none=`tput sgr0`
yellow='\033[1;33m'
yellow_background='\033[7;93m'
blue_background='\033[7;94m'
purple='\033[1;35m'
lightred='\033[1;31m'
lightred_background='\033[7;31m'
blue_background_white_text='\033[97;44m'
white_background_blue_text='\033[94;47m'
bold=$(tput bold)

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
HOME_DIR=$(eval echo "~/InsaneAppPurchaser")
SCRIPT_NAME=$(basename "$0")

center_message_input() {
    local message="$1"
    local top_border_char="$2"
    local bottom_border_char="$3"
    local input_prompt="$4"
    local title="$5"
    local variable="$6"

    # Get the terminal dimensions
    local rows=$(tput lines)
    local cols=$(tput cols)

    # Calculate the number of lines in the message
    #local message_lines=$(echo "$message" | wc -l)
    
    if [[ "$variable" == "--bsod-sad" ]]; then
        local message_lines=$(($(echo "$message" | wc -l) + 10))
    else
        local message_lines=$(echo "$message" | wc -l)
    fi
    
    # Calculate the vertical position for the message, considering the number of message lines
    
    local top_padding=$(( (rows - message_lines) / 2 ))
        
    if [[ "$variable" == "--no-input" ]]; then
        local bottom_padding=$(( rows - message_lines - top_padding - 1 ))
    else
        local bottom_padding=$(( rows - message_lines - top_padding - 2 ))
    fi
    
    # Clear the screen
    #clear
    echo -e "\n"
    
    if [[ "$variable" == "--bsod" ]] || [[ "$variable" == "--bsod-sad" ]]; then
        printf "${white_background_blue_text}${bold}"
    fi

    # Calculate the padding for the title
    local title_length=${#title}
    local left_padding=$(( (cols - title_length) / 2 ))
    local right_padding=$(( cols - title_length - left_padding ))

    # Print the top border with the title centered
    printf "%*s" "$left_padding" | tr ' ' "$top_border_char"
    printf "%s" "$title"
    #printf "%*s\n" "$right_padding" | tr ' ' "$top_border_char"
    
    if [[ "$variable" == "--bsod" ]] || [[ "$variable" == "--bsod-sad" ]]; then
        printf "%*s" "$right_padding" | tr ' ' "$top_border_char"
        printf "${none}${blue_background_white_text}\n"
    else
        printf "%*s\n" "$right_padding" | tr ' ' "$top_border_char"
    fi

    # Print empty lines until reaching the vertical position
    for ((i = 1; i < top_padding; i++)); do
        printf "\n"
    done
    
    # Print the message aligned to the left
    #echo -e "$message"
    
    if [[ "$variable" == "--bsod-sad" ]]; then
        echo -e "${blue_background_white_text}               ##${blue_background_white_text}
${blue_background_white_text}              ## ${blue_background_white_text}
${blue_background_white_text}     ##      ##  ${blue_background_white_text}
${blue_background_white_text}             ##  ${blue_background_white_text}
${blue_background_white_text}             ##  ${blue_background_white_text}
${blue_background_white_text}     ##      ##  ${blue_background_white_text}
${blue_background_white_text}              ## ${blue_background_white_text}
${blue_background_white_text}               ##${blue_background_white_text}
${blue_background_white_text}${blue_background_white_text}
${blue_background_white_text}${blue_background_white_text}
$message"
    else
        echo -e "$message"
    fi

    # Print empty lines until reaching the bottom row
    for ((i = 0; i < bottom_padding; i++)); do
        printf "\n"
    done
    
    if [[ "$variable" == "--bsod" ]] || [[ "$variable" == "--bsod-sad" ]]; then
        printf "${white_background_blue_text}${bold}"
    fi
    
    # Print the bottom border
    #printf '%*s\n' "$cols" '' | tr ' ' "$bottom_border_char"
    
    if [[ "$variable" == "--bsod" ]] || [[ "$variable" == "--bsod-sad" ]]; then
        printf '%*s' "$cols" '' | tr ' ' "$bottom_border_char"
        printf "${none}${blue_background_white_text}\n"
    elif [[ "$variable" == "--no-input" ]]; then
        printf '%*s' "$cols" '' | tr ' ' "$bottom_border_char"
    else
        printf '%*s\n' "$cols" '' | tr ' ' "$bottom_border_char"
    fi

    # Read user input with the provided prompt
    if [[ "$variable" == "--long" ]]; then
        read -p "$input_prompt" -r choice
    elif [[ "$variable" == "--sensitive" ]]; then
        read -p "$input_prompt" -r -s choice
    elif [[ "$variable" != "--no-input" ]]; then
        read -p "$input_prompt" -r -n 1 choice
    fi
    
    printf "${none}"
    
    if [[ "$variable" != "--no-input" ]]; then
        export choice
    fi
}

main_menu() {

    local choices='[[ "$choice" != "1" && "$choice" != "2" && "$choice" != "3" ]]'
    local message="${bold}Insane iOS App Purchaser, $version by ${cyan}@disfordottie${none}


This script purchases apps in bulk using a list of Bundle IDs.

1. Use my own list

2. Browse existing lists

3. Settings"


    # Check if the file exists
    if [[ -f "${HOME_DIR}/workingList.txt" ]]; then
        #exists
        message=$(cat <<EOF
$message
   
${yellow_background}                                                  ${yellow_background}
${yellow_background}${bold}   Warning!                                       ${yellow_background}
   Last time you ran this script it didnt         ${yellow_background}
   finish purchasing all the apps on the list.    ${yellow_background}
                                                  ${yellow_background}
   To pick up from where you left off, press R.   ${yellow_background}
                                                  ${none}
EOF
)
    
        choices='[[ "$choice" != "1" && "$choice" != "2" && "$choice" != "3" && "$choice" != "R" && "$choice" != "r" ]]'
    
    fi
    
    center_message_input "$message" '#' '#' "Choice: " " Main Menu "

    while eval "$choices"; do
        center_message_input "$message

${lightred}${bold}\"$choice\" is not a valid option${none}" '#' '#' "Choice: " " Main Menu "
    done
    
    local list_option=$choice
    
    if [ "$list_option" = "r" ] || [ "$list_option" = "R" ]; then
        pruchase "workingList"
        return
    fi
    
    check_ipatool

    if [ "$list_option" == "1" ]; then
        manual
    elif [ "$list_option" == "2" ]; then
        existing
    elif [ "$list_option" == "3" ]; then
        settings
    fi

}

settings() {
    local signOutMessage=""
    while True; do
        # Check if the directory exists
        if [ -f ~/InsaneAppPurchaser/enableLogging ]; then
            local loggingStatus="Disable Purchase Logging"
            local loggingMessage="
            
${green_background}                                                       ${none}
${green_background}   Logs are currently enabled and will be saved to:    ${none}
${green_background}      ~/InsaneAppPurchaser/logs/                       ${none}
${green_background}   Lists will be kept of already purchased apps and    ${none}
${green_background}   invalid apps to save time proccessing big lists.    ${none}
${green_background}                                                       ${none}"
        else
            local loggingStatus="Enable Purchase Logging (Recommended)"
            local loggingMessage=""
        fi
    
        local message="${bold}Settings${none}

1. ${loggingStatus}

2. Sign out of ipatool

3. Re-Purchase Failed Apps

4. Main Menu${loggingMessage}${signOutMessage}"

        center_message_input "$message" '#' '#' "Choice: " " Settings "
    
        while [[ "$choice" != "1" && "$choice" != "2" && "$choice" != "3" && "$choice" != "4" ]]; do
            center_message_input "$message

${lightred}${bold}\"$choice\" is not a valid option${none}" '#' '#' "Choice: " " Settings "
        done
    
        if [ "$choice" == "1" ]; then
            if [ ! -f ~/InsaneAppPurchaser/enableLogging ]; then
                touch ~/InsaneAppPurchaser/enableLogging
            else
                rm ~/InsaneAppPurchaser/enableLogging
            fi
            
            signOutMessage=""
        elif [ "$choice" == "2" ]; then
            ipatool auth revoke
            signOutMessage="
            
${yellow_background}                                                       ${none}
${yellow_background}   ipatool has been been signed out                    ${none}
${yellow_background}                                                       ${none}"
        elif [ "$choice" == "3" ]; then
            local last_line=$(ipatool auth info --format json 2>&1 | tail -n 1)
            local appleID=$(echo "$last_line" | jq -r '.email')
            if [ -f "${HOME_DIR}/logs/${appleID}/try_again.txt" ]; then
                cp "${HOME_DIR}/logs/${appleID}/try_again.txt" "${HOME_DIR}/existingList.txt"
                pruchase "existingList"
                return
            else
                center_message_input "   No list of purchases to retry could be found." '#' '#' "Press Any Key To Continue: " " Womp Womp " --bsod-sad
                main_menu
                return
            fi
        else
            main_menu
            return
        fi
    done
}

manual() {

    center_message_input "Before starting make sure you have a list of Bundle ID's
saved to the directory the script is currently in:

${purple}${bold}(\"$SCRIPT_DIR/bundleIds.txt\")${none}

The file should be in the formt: bundle id (new line) bundle id (new line) etc.

" '#' '#' "Press Any Key To Start: " " Own List "
    
    if [ -e "$SCRIPT_DIR/bundleIds.txt" ]; then
        local line_count=$(awk 'END {print NR}' "$SCRIPT_DIR/bundleIds.txt")
        
        if [ -f "${HOME_DIR}/enableLogging" ]; then
            center_message_input "${purple}${bold}Ready to start.${none}
    
${bold}Your list contains $line_count apps.${none}" '#' '#' "Press Any Key To Continue: " " Own List "
        
            local message="${yellow}${bold}Skip apps you already own?${none}
    
${bold}Because you have logging enabled you ca skip apps you already own.${none}"

            center_message_input "${message}" '#' '#' "Skip Owned Apps? [y/n]: " " Own List "
            
            while [[ "$choice" != "y" && "$choice" != "Y" && "$choice" != "n" && "$choice" != "N" ]]; do
                center_message_input "${message}
            
${lightred}${bold}\"$choice\" is not a valid option${none}" '#' '#' "Skip Owned Apps? [y/n]: " " Own List "
            done
        
            if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
                clean_list "bundleIds"
                pruchase "cleanList"
            else
                pruchase "bundleIds"
            fi
            
        else
            enter_message_input "${purple}${bold}Ready to start.${none}
    
${bold}Your list contains $line_count apps.${none}" '#' '#' "Press Any Key To Start: " " Own List "
            pruchase "bundleIds"
        fi
             
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
    done < <(echo "$response" | jq -r '.[] | select(.type == "file") | .name' | sed 's/\.txt$//')
    #no jq done < <(echo "$response" | grep -o '"name": "[^"]*"' | sed 's/"name": "//' | sed 's/\.txt$//')
    
    choice=-1
    if [ "$file_count" -eq 0 ]; then
        #no lists
        center_message_input "${lightred}${bold}No lists where found on the server.${none}

Github couldnt be reached.

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
    # no jq local url=$(echo "$response" | grep -o '"download_url": "[^"]*"' | sed -n "${choice}s/.*: \"\(.*\)\"/\1/p")
    local url=$(echo "$response" | jq -r ".[$((choice-1))] | select(.type == \"file\") | .download_url")

    local url=$(echo "$url" | sed 's/ /%20/g; s/&/%26/g; s/+/%2B/g')
    echo "$url"
    
    local file_name=$(basename "$url" | sed 's/\.[^.]*$//')

    # Download the file as appIds.txt
    curl -o "${HOME_DIR}/existingList.txt" "$url"

    file_name=$(echo "$file_name" | sed 's/%20/ /g')
    file_name=$(echo "$file_name" | sed 's/%26/\&/g')
    file_name=$(echo "$file_name" | sed 's/%2B/+/g')
    echo "File downloaded as 'existingList.txt'. (Original: $file_name)"
    
    #######show info about list
    local info_url=${url/.txt/_INFO.txt}
    info_url="${info_url/Lists/Lists_INFO}"
    
    if curl --output /dev/null --silent --head --fail "${info_url}"; then
        echo "MESSAGE HAS INFO FILE"
        # If the file exists, download and display its contents
        local wiseWords=$(curl -s "$info_url")
        local page_count=$(echo "$wiseWords" | jq -r '.page_count')
        for ((CURRENTPAGE=1; CURRENTPAGE<=page_count; CURRENTPAGE++)); do
            echo "$CURRENTPAGE"
            local key_action=""
            if [ $CURRENTPAGE -eq $page_count ]; then
                key_action="Start"
            else
                key_action="Continue"
            fi
            
            local page_info=""
            if [ "$page_count" -gt 1 ]; then
                page_info=" | Page ${CURRENTPAGE} of ${page_count}"
            fi
            
            local page_contents=$(echo "$wiseWords" | jq -r ".page${CURRENTPAGE}")
            page_contents="$(eval "echo -e \"$page_contents\"")"
            
            center_message_input "$page_contents" '#' '#' "Press Any Key To ${key_action}: " " List Information${page_info} "
        done
    else
        echo "No findo file not found at $info_url"
    fi
    
    local line_count=$(awk 'END {print NR}' "${HOME_DIR}/existingList.txt")
    
    if [ -f "${HOME_DIR}/enableLogging" ]; then
        center_message_input "${purple}${bold}Ready to start.${none}
    
${bold}The list \"$file_name\" contains $line_count apps.${none}" '#' '#' "Press Any Key To Continue: " " Existing List "
        
        local message="${yellow}${bold}Skip apps you already own?${none}
    
${bold}Because you have logging enabled you can skip apps you already own.${none}"

        center_message_input "${message}" '#' '#' "Skip Owned Apps? [y/n]: " " Existing List "
        
        while [[ "$choice" != "y" && "$choice" != "Y" && "$choice" != "n" && "$choice" != "N" ]]; do
            center_message_input "${message}
            
${lightred}${bold}\"$choice\" is not a valid option${none}" '#' '#' "Skip Owned Apps? [y/n]: " " Existing List "
        done
        
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            clean_list "existingList"
            pruchase "cleanList"
        else
            pruchase "existingList"
        fi
            
    else
        enter_message_input "${purple}${bold}Ready to start.${none}
    
${bold}The list \"$file_name\" contains $line_count apps.${none}" '#' '#' "Press Any Key To Start: " " Existing List "
        pruchase "existingList"
    fi
    
}

pruchase() {

    local success_count=0                   # successful purchase
    
    local license_exists_count=0            # app already owned
    local json_unmarshal_count=0            # wierd error
    local no_host_count=0                   # couldnt connect to apples servers
    local app_not_found_count=0             # app not in this country / region or is invalid / removed
    local paid_app_count=0                  # app costs money and will add to never try again list
    local multiple_requests_count=0         # too many requests to buy at once
    local failed_count=0                    # title
    
    #local account_errors_count=0         # too many requests to buy at once
    #local country_code_count=0              # happens when account is locked or not signed in RE LOGIN
    #local password_changed_count=0          # account lockedd alternate error RE LOGIN
    
    local other_error_count=0      # error not listed in any other list
    
    
    local last_line=""
    
    # make log files
    if [ -f "${HOME_DIR}/enableLogging" ]; then
    
        last_line=$(ipatool auth info --format json 2>&1 | tail -n 1)
        appleID=$(echo "$last_line" | jq -r '.email')
        
        #if files/folders dont exist make them
        if [ ! -d "${HOME_DIR}/logs/${appleID}" ]; then
            mkdir -p "${HOME_DIR}/logs/${appleID}"
        fi
        
        #owned items
        if [ ! -f "${HOME_DIR}/logs/${appleID}/owned_items.txt" ]; then
            touch "${HOME_DIR}/logs/${appleID}/owned_items.txt"
        fi
        
        #try again
        if [ ! -f "${HOME_DIR}/logs/${appleID}/try_again.txt" ]; then
            touch "${HOME_DIR}/logs/${appleID}/try_again.txt"
        fi
        
        #do not bother
        if [ ! -f "${HOME_DIR}/logs/${appleID}/paid_items.txt" ]; then
            touch "${HOME_DIR}/logs/${appleID}/paid_items.txt"
        fi
        
        #failed
        if [ ! -f "${HOME_DIR}/logs/${appleID}/failed_items.txt" ]; then
            touch "${HOME_DIR}/logs/${appleID}/failed_items.txt"
        fi
    fi
    
    
    local file_name="$1"
    local total_apps=0
    
    local did_workingInfo_exist=0
    
    #echo "$INFILE"
    if [ "$file_name" = "existingList" ]; then
    
        # Define the input file
        local INFILE="${HOME_DIR}/existingList.txt"
        
        cp "${INFILE}" "${HOME_DIR}/workingList.txt"
        INFILE="${HOME_DIR}/workingList.txt"
        total_apps=$(awk 'END {print NR}' "${HOME_DIR}/existingList.txt")
        
        touch "${HOME_DIR}/workingInfo.json"
        
    elif [ "$file_name" = "bundleIds" ]; then
    
        # Define the input file
        local INFILE="${SCRIPT_DIR}/$file_name.txt"
        INFILE=$(eval echo "$INFILE")
        
        cp "${INFILE}" "${HOME_DIR}/workingList.txt"
        INFILE="${HOME_DIR}/workingList.txt"
        total_apps=$(awk 'END {print NR}' "${SCRIPT_DIR}/bundleIds.txt")
        
        touch "${HOME_DIR}/workingInfo.json"
        
    elif [ "$file_name" = "cleanList" ]; then
    
        # Define the input file
        local INFILE="${HOME_DIR}/cleanList.txt"
        INFILE=$(eval echo "$INFILE")
        
        cp "${INFILE}" "${HOME_DIR}/workingList.txt"
        INFILE="${HOME_DIR}/workingList.txt"
        total_apps=$(awk 'END {print NR}' "${HOME_DIR}/cleanList.txt")
        
        touch "${HOME_DIR}/workingInfo.json"
        
    else
    
        local INFILE="${HOME_DIR}/workingList.txt"
        
        # Count the number of lines in the file
        local line_count=$(wc -l < "$INFILE" | tr -d ' ')

        # Check if the last character of the file is a newline
        local last_char=$(tail -c 1 "$INFILE")

        # If the last character is not a newline, increment the line count
        if [ "$last_char" != "" ]; then
            ((line_count++))
        fi
        
        if [ -f "${HOME_DIR}/workingInfo.json" ]; then
            did_workingInfo_exist=1
            # Specify the path to the JSON file
            local json_file="${HOME_DIR}/workingInfo.json"

            # Load JSON content into variables
            total_apps=$(jq -r '.total_apps' "$json_file")
            success_count=$(jq -r '.success_count' "$json_file")
            license_exists_count=$(jq -r '.license_exists_count' "$json_file")
            json_unmarshal_count=$(jq -r '.json_unmarshal_count' "$json_file")
            no_host_count=$(jq -r '.no_host_count' "$json_file")
            app_not_found_count=$(jq -r '.app_not_found_count' "$json_file")
            paid_app_count=$(jq -r '.paid_app_count' "$json_file")
            multiple_requests_count=$(jq -r '.multiple_requests_count' "$json_file")
            failed_count=$(jq -r '.failed_count' "$json_file")
            other_error_count=$(jq -r '.other_error_count' "$json_file")
            
            local display_total=" out of ${total_apps}"
        fi
        
        center_message_input "${purple}There are ${line_count}${display_total} apps left to proccess.${none}" '#' '#' "Press Any Key To Start: " " Resume "

    fi

    local line_number=1

    local rows=$(tput lines)
    for ((i=1; i<=rows; i++)); do
        echo -e "\n"
    done
    
    local wokring_file_total=$(awk 'END {print NR}' "${HOME_DIR}/workingList.txt")
    
    # Read the input file line by line using a for loop
    local IFS=$'\n' # set the Internal Field Separator to newline
    
    for LINE in $(cat $INFILE)
    do
        while True; do
            if [ "$total_apps" -gt 0 ]; then
                echo "### Processing line number: $(( $line_number + ($total_apps - $wokring_file_total))) of ${total_apps} ($((( $total_apps - ( $line_number + ($total_apps - $wokring_file_total))) + 1 )) remaining)"
                echo "### $LINE"
            else
                echo "### Processing line number: $line_number"
                echo "### $LINE"
            
            fi
        
            #ipatool purchase -b "$LINE"
            last_line=$(ipatool purchase -b "$LINE" 2>&1 | tail -n 1)
            echo "$last_line"


            # Check the last line for the specific phrases and tally their occurrences
        
            ############ OWNED_ITEMS LIST
        
            if [[ "$last_line" =~ "success" ]] && [[ "$last_line" =~ "true" ]] && [[ "$last_line" =~ "INF" ]]; then
                ((success_count++))
                if [ -f "${HOME_DIR}/enableLogging" ]; then
                    add_to_log owned_items $LINE
                fi
                break
            
            elif [[ "$last_line" =~ "license already exists" ]]; then
                ((license_exists_count++))
                if [ -f "${HOME_DIR}/enableLogging" ]; then
                    add_to_log owned_items $LINE
                fi
                break
                
            elif [[ "$last_line" =~ "You can't restore this app on this device" ]]; then
                ((license_exists_count++))
                if [ -f "${HOME_DIR}/enableLogging" ]; then
                    add_to_log owned_items $LINE
                fi
                break
                
            ############ FAILED_ITEMS LIST
            
            elif [[ "$last_line" =~ "failed to unmarshal json" ]]; then
                ((json_unmarshal_count++))
                if [ -f "${HOME_DIR}/enableLogging" ]; then
                    add_to_log failed_items $LINE
                fi
                break
            
            elif [[ "$last_line" =~ "app not found" ]]; then
                ((app_not_found_count++))
                if [ -f "${HOME_DIR}/enableLogging" ]; then
                    add_to_log failed_items $LINE
                fi
                break
            
            ############ TRY_AGAIN LIST
        
            elif [[ "$last_line" =~ "no such host" ]]; then
                ((no_host_count++))
                if [ -f "${HOME_DIR}/enableLogging" ]; then
                    add_to_log try_again $LINE
                fi
                break
        
            elif [[ "$last_line" =~ "failed to purchase app" ]]; then
                ((failed_count++))
                if [ -f "${HOME_DIR}/enableLogging" ]; then
                    add_to_log try_again $LINE
                fi
                break
            
            elif [[ "$last_line" =~ "temporarily unable to process your request" ]]; then
                ((multiple_requests_count++))
                if [ -f "${HOME_DIR}/enableLogging" ]; then
                    add_to_log try_again $LINE
                fi
                break
        
            ############ (ACCOUNT LOCKED)
        
            elif [[ "$last_line" =~ "country code mapping for store front" ]] || [[ "$last_line" =~ "Your password has changed" ]]; then
                local paused_message="${yellow}Purchasing has been automatically paused.${none}

An account related error has occured, these are generally
caused by your Apple ID being locked/disabled.

Please check if your account is locked (if so unlock it),
then type \"CONTINUE\" below to sign into ipatool again.

Once resolved, purchasing will continue as normal."
            
                center_message_input "$paused_message" '#' '#' "Type \"CONTINUE\" to sign into ipatool: " " Paused " --long

                while [[ "$choice" != "CONTINUE" && "$choice" != "continue" && "$choice" != "Continue" ]]; do
                    center_message_input "$paused_message

${lightred}${bold}\"$choice\" is not a valid option${none}" '#' '#' "Type \"CONTINUE\" to sign into ipatool: " " Paused " --long
                done
            
                ipatool auth revoke
            
                check_ipatool
                
                last_line=$(ipatool auth info --format json 2>&1 | tail -n 1)
                appleID=$(echo "$last_line" | jq -r '.email')
            
            ############ PAID_ITEMS LIST
            elif [[ "$last_line" =~ "paid" ]]; then
                ((paid_app_count++))
                if [ -f "${HOME_DIR}/enableLogging" ]; then
                    add_to_log paid_items $LINE
                fi
                break
        
            ############ UNKOWN SO ADD TO TRY_AGAIN LIST (AGAIN)
            else
                ((other_error_count++))
                if [ -f "${HOME_DIR}/enableLogging" ]; then
                    add_to_log try_again $LINE
                fi
                break
            fi
        done
        
        # remove line from working file
        sed -i '' "/^$LINE$/d" "$INFILE"
        
        local json_contents="$(cat <<EOF
        {
            "total_apps": "$total_apps",
            "success_count": "$success_count",
            "license_exists_count": $license_exists_count,
            "json_unmarshal_count": "$json_unmarshal_count",
            "no_host_count": "$no_host_count",
            "app_not_found_count": $app_not_found_count,
            "paid_app_count": "$paid_app_count",
            "multiple_requests_count": "$multiple_requests_count",
            "failed_count": $failed_count,
            "other_error_count": "$other_error_count"
        }
        EOF
        )"
        
        echo "$json_contents" > "${HOME_DIR}/workingInfo.json"
            
        # Verify the removal
        #if grep -Fxq "$LINE" "$INFILE"; then
            #echo "The line was not removed."
        #else
            #echo "The line was successfully removed."
        #fi
        
        ((line_number++))
    done
    
    rm "$INFILE"
    rm "${HOME_DIR}/workingInfo.json"
    rm "${HOME_DIR}/existingList.txt"
    
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
    if (( success_count > 0 && (license_exists_count > 0 || json_unmarshal_count > 0 || no_host_count > 0 || app_not_found_count > 0 || other_error_count > 0 || paid_app_count > 0 || multiple_requests_count > 0 || failed_count > 0) )); then
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
    
    #paid_app_count erros
    if [ "$paid_app_count" -eq 1 ]; then
        status_message=$(cat <<EOF
$status_message
${red}${bold}1 app couldnt be pruchased because it costs money.${none}
EOF
)
    elif [ "$paid_app_count" -gt 1 ]; then
        status_message=$(cat <<EOF
$status_message
${red}${bold}$paid_app_count apps couldnt be pruchased because they cost money.${none}
EOF
)
    fi
    
    #multiple_requests_count erros
    if [ "$multiple_requests_count" -eq 1 ]; then
        status_message=$(cat <<EOF
$status_message
${red}${bold}1 app couldnt be pruchased because because of multiple simultaneous requests.${none}
EOF
)
    elif [ "$multiple_requests_count" -gt 1 ]; then
        status_message=$(cat <<EOF
$status_message
${red}${bold}$multiple_requests_count apps couldnt be pruchased because of multiple simultaneous requests.${none}
EOF
)
    fi
    
    #failed_count erros
    if [ "$failed_count" -eq 1 ]; then
        status_message=$(cat <<EOF
$status_message
${red}${bold}1 app failed to purchase for unkown reasons.${none}
EOF
)
    elif [ "$failed_count" -gt 1 ]; then
        status_message=$(cat <<EOF
$status_message
${red}${bold}$failed_count apps failed to purchase for unkown reasons.${none}
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
    
    
    if [ "$did_workingInfo_exist" -eq 1 ] && [ "$1" = "workingList" ]; then
        status_message=$(cat <<EOF
${purple}${bold}$total_apps apps total were processed.${none}
$status_message
EOF
)
    elif [ "$1" = "workingList" ]; then
        status_message=$(cat <<EOF
${purple}${bold}$line_number apps total were processed this session.${none}
$status_message
EOF
)
    else
        status_message=$(cat <<EOF
${purple}${bold}$line_number apps total were processed.${none}
$status_message
EOF
)
    fi


    if [ "$line_number" -eq 0 ]; then
        center_message_input "${lightred}${bold}The list was empty, hence no apps where purchased.${none}" '#' '#' "Press Any Key To Return To Main Menu: " " Process Complete "
    else
        center_message_input "$status_message" '#' '#' "Press Any Key To Return To Main Menu: " " Process Complete "
    fi
    
    main_menu
    return
}


check_for_updates() {

    # Define variables
    local REPO_OWNER="disfordottie"
    local REPO_NAME="insaneAppPurchaser"
    local SCRIPT_FILE_NAME="Insane-iOS-App-Purchaser.sh"
    local LATEST_VERSION_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest"  # GitHub API URL

    # Get current version
    local CURRENT_VERSION=$version

    # Fetch latest release info from GitHub
    local LATEST_RELEASE_INFO=$(curl -s "$LATEST_VERSION_URL")
    
    # Check if curl failed
    if [ $? -ne 0 ]; then
        return
    fi
    
    local LATEST_VERSION=$(echo "$LATEST_RELEASE_INFO" | jq -r '.tag_name')  # Assuming tag_name represents the version
    
    if [ ${#LATEST_VERSION} -eq 0 ]; then
        return
    fi

    # Compare versions
    if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    
        local padded_message="Your version: ${version}, New version: ${LATEST_VERSION}"

        while [ ${#padded_message} -lt 49 ]; do
            padded_message=" ${padded_message} "
        done
    
        while [ ${#padded_message} -lt 50 ]; do
            padded_message="${padded_message} "
        done
    
        local message=""
        
        local lines=(
            "${green_background}${bold}                                                  ${green_background}${none}"
            "${green_background}${bold}             An Update Is Available!              ${green_background}${none}"
            "${green_background}${bold}                                                  ${green_background}${none}"
            "${green_background}${bold}${padded_message}${green_background}${none}"
            "${green_background}${bold}                                                  ${green_background}${none}"
            "${green_background}${bold}        Would you like to install it now?         ${green_background}${none}"
            "${green_background}${bold}                                                  ${green_background}${none}"
        )
    
        local cols=$(tput cols)
    
        # Loop through each line and process it
        for line in "${lines[@]}"; do
    
            local title_length=50
            local left_padding=$(( (cols - title_length) / 2 ))

            local padding=$(printf "%*s" "$left_padding" | tr ' ' " ")
        
            local padded_line="${padding}${line}"
        
            message=$(cat <<EOF
$message
${padded_line}
EOF
)
        done
    
        center_message_input "$message" '#' '#' "Update? [y/n]: " " Update Available "
        
        local fill_space=""
        
        while [[ "$choice" != "y" && "$choice" != "n" && "$choice" != "Y" && "$choice" != "N" ]]; do
            
            
            if [ "${#choice}" -eq 0 ]; then
                fill_space=" "
            else
                fill_space=""
            fi
            center_message_input "$message

${padding}${lightred_background}${bold}                                                  ${lightred_background}${none}
${padding}${lightred_background}${bold}            \"${choice}${fill_space}\" is not a valid option             ${none}
${padding}${lightred_background}${bold}                                                  ${lightred_background}${none}" '#' '#' "Update? [y/n]: " " Update Available "
        done
        
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            # Get the download URL for the latest release asset
            DOWNLOAD_URL=$(echo "$LATEST_RELEASE_INFO" | jq -r ".assets[] | select(.name == \"$SCRIPT_FILE_NAME\") | .browser_download_url")

            # Download the latest version
            curl -L -o "${SCRIPT_DIR}/Insane-iOS-App-Purchaser-Update.sh" "$DOWNLOAD_URL"
            
            # Check if curl failed
            if [ $? -ne 0 ]; then
                message=""
        
                lines=(
                    "${lightred_background}${bold}                                                  ${lightred_background}${none}"
                    "${lightred_background}${bold}                  Update Failed.                  ${lightred_background}${none}"
                    "${lightred_background}${bold}                                                  ${lightred_background}${none}"
                    "${lightred_background}${bold}          The update failed to download.          ${lightred_background}${none}"
                    "${lightred_background}${bold}                                                  ${lightred_background}${none}"
                )
    
                cols=$(tput cols)
    
                # Loop through each line and process it
                for line in "${lines[@]}"; do
    
                    title_length=50
                    left_padding=$(( (cols - title_length) / 2 ))

                    padding=$(printf "%*s" "$left_padding" | tr ' ' " ")
        
                    padded_line="${padding}${line}"
        
                    message=$(cat <<EOF
$message
${padded_line}
EOF
)
                done
    
                center_message_input "$message" '#' '#' "Press Any Key To Return To Main Menu: " " Update Failed "
                
                return
            fi
    
            local OLD_SCRIPT="${SCRIPT_DIR}/${SCRIPT_NAME}"
            local NEW_SCRIPT="$SCRIPT_DIR/Insane-iOS-App-Purchaser-Update.sh"
            
            local file_size=$(wc -c < "$NEW_SCRIPT")

            # Check if the file size is less than 100 characters
            if [ "$file_size" -lt 100 ]; then
            
                message=""
        
                lines=(
                    "${lightred_background}${bold}                                                  ${lightred_background}${none}"
                    "${lightred_background}${bold}                  Update Failed.                  ${lightred_background}${none}"
                    "${lightred_background}${bold}                                                  ${lightred_background}${none}"
                    "${lightred_background}${bold}          The update failed to download.          ${lightred_background}${none}"
                    "${lightred_background}${bold}                                                  ${lightred_background}${none}"
                )
    
                cols=$(tput cols)
    
                # Loop through each line and process it
                for line in "${lines[@]}"; do
    
                    title_length=50
                    left_padding=$(( (cols - title_length) / 2 ))

                    padding=$(printf "%*s" "$left_padding" | tr ' ' " ")
        
                    padded_line="${padding}${line}"
        
                    message=$(cat <<EOF
$message
${padded_line}
EOF
)
                done
    
                center_message_input "$message" '#' '#' "Press Any Key To Return To Main Menu: " " Update Failed "
                
                return
            fi

            # Replace the contents of the old script with the new one
            cat "$NEW_SCRIPT" > "$OLD_SCRIPT"
    
            # Replace the current script with the new version
            #mv "${SCRIPT_DIR}/Insane-iOS-App-Purchaser-Update.sh" "$SCRIPT_DIR/$SCRIPT_NAME"
    
            ${SCRIPT_DIR}/${SCRIPT_NAME} "updated"
        else
            return
        fi
    fi
    
}

updated() {
    rm "$SCRIPT_DIR/Insane-iOS-App-Purchaser-Update.sh"

    local padded_message="Successfully updated to version ${version}"

    while [ ${#padded_message} -lt 49 ]; do
        # Append a character to the string (for demonstration)
        padded_message=" ${padded_message} "
    done
    
    while [ ${#padded_message} -lt 50 ]; do
        # Append a character to the string (for demonstration)
        padded_message="${padded_message} "
    done
    
    local message=""
        
    local lines=(
        "${green_background}${bold}                                                  ${green_background}${none}"
        "${green_background}${bold}                 Update Complete.                 ${green_background}${none}"
        "${green_background}${bold}                                                  ${green_background}${none}"
        "${green_background}${bold}${padded_message}${green_background}${none}"
        "${green_background}${bold}                                                  ${green_background}${none}"
    )
    
    local cols=$(tput cols)
    
    # Loop through each line and process it
    for line in "${lines[@]}"; do
    
        local title_length=50
        local left_padding=$(( (cols - title_length) / 2 ))

        local padding=$(printf "%*s" "$left_padding" | tr ' ' " ")
        
        local padded_line="${padding}${line}"
        
        message=$(cat <<EOF
$message
${padded_line}
EOF
)
    done
    
    center_message_input "$message" '#' '#' "Press Any Key To Continue: " " Update Complete "
    
}

add_to_log() {

    local file="${1}.txt"
    local dir="${HOME_DIR}/logs/${appleID}"

    # Check if the string already exists in the file
    if ! grep -Fxq "$2" "${dir}/${file}"; then
        # If not, append the string to the file
        echo "$2" >> "${dir}/${file}"
    fi
}

clean_list() {
    local file_name="$1"
    if [ "$file_name" = "existingList" ]; then
    
        # Define the input file
        local INFILE="${HOME_DIR}/existingList.txt"
        
        cp "${INFILE}" "${HOME_DIR}/cleanList.txt"
        INFILE="${HOME_DIR}/cleanList.txt"
        
    elif [ "$file_name" = "bundleIds" ]; then
    
        # Define the input file
        local INFILE="${SCRIPT_DIR}/bundleIds.txt"
        
        cp "${INFILE}" "${HOME_DIR}/cleanList.txt"
        INFILE="${HOME_DIR}/cleanList.txt"
    fi
            
            
    last_line=$(ipatool auth info --format json 2>&1 | tail -n 1)
    appleID=$(echo "$last_line" | jq -r '.email')
    
    local removed_items_count=0
    
    #owned items
    if [ -f "${HOME_DIR}/logs/${appleID}/owned_items.txt" ]; then
        for LINE in $(cat "${HOME_DIR}/logs/${appleID}/owned_items.txt"); do
            if grep -q "^$LINE$" "$INFILE"; then
                sed -i '' "/^$LINE$/d" "$INFILE"
                ((removed_items_count++))
            fi
        done
    fi
        
    #do not bother
    if [ -f "${HOME_DIR}/logs/${appleID}/paid_items.txt" ]; then
        for LINE in $(cat "${HOME_DIR}/logs/${appleID}/paid_items.txt"); do
            if grep -q "^$LINE$" "$INFILE"; then
                sed -i '' "/^$LINE$/d" "$INFILE"
                ((removed_items_count++))
            fi
        done
    fi
    
    if [ "$removed_items_count" -eq 0 ]; then
        center_message_input "The list of apps you already owned was empty, hence no apps will be skipped." '#' '#' "Press Any Key To Start: " " Clean List "
    elif [ "$removed_items_count" -eq 1 ]; then
        center_message_input "1 app you already own will be skipped." '#' '#' "Press Any Key To Start: " " Clean List "
    else
        center_message_input "${removed_items_count} apps you already own will be skipped." '#' '#' "Press Any Key To Start: " " Clean List "
    fi
}

install_ipatool() {
    # Define variables
    RELEASE_API_URL="https://api.github.com/repos/majd/ipatool/releases/latest"
    INSTALL_DIR="/usr/local/bin"
    
    if [[ "$1" == "homebrew" ]]; then
        
        brew upgrade ipatool
        return 0
        
    fi

    # Fetch the latest release tag
    LATEST_RELEASE_INFO=$(curl -s "$RELEASE_API_URL")
    LATEST_VERSION=$(echo "$LATEST_RELEASE_INFO" | jq -r '.tag_name' | sed 's/^v//')
    
    # no jq LATEST_VERSION=$(echo "$LATEST_RELEASE_INFO" | grep -o '"tag_name": *"[^"]*' | sed -E 's/"tag_name": *"v?//')


    # Detect architecture
    ARCH=$(uname -m)
    if [[ "$ARCH" == "arm64" ]]; then
        ARCHIVE_NAME="ipatool-${LATEST_VERSION}-macos-arm64.tar.gz"
        BINARY_NAME="ipatool-${LATEST_VERSION}-macos-arm64"
    else
        ARCHIVE_NAME="ipatool-${LATEST_VERSION}-macos-amd64.tar.gz"
        BINARY_NAME="ipatool-${LATEST_VERSION}-macos-amd64"
    fi

    mkdir -p "${HOME_DIR}/temp"

    # Download the appropriate release archive
    DOWNLOAD_URL="https://github.com/majd/ipatool/releases/download/v$LATEST_VERSION/$ARCHIVE_NAME"
    curl -L -o "${HOME_DIR}/temp/$ARCHIVE_NAME" "$DOWNLOAD_URL"
            
    # Extract the archive
    tar -xvzf "${HOME_DIR}/temp/$ARCHIVE_NAME" -C "${HOME_DIR}/temp/" || { echo -e "${lightred}${bold}Error: Failed to extract ${ARCHIVE_NAME}${none}"; rm -rf "${HOME_DIR}/temp/"; return 1; }

    if [[ -f "${HOME_DIR}/temp/bin/${BINARY_NAME}" ]]; then
        mv "${HOME_DIR}/temp/bin/${BINARY_NAME}" "$INSTALL_DIR/ipatool"
    else
        echo -e "${lightred}${bold}Error: Extracted binary not found.${none}"
        rm -rf "${HOME_DIR}/temp/"
        return 1
    fi

    # Clean up
    rm -rf "${HOME_DIR}/temp/"
            
    local message=""
        
    local lines=(
        "${yellow_background}${bold}                                                  ${yellow_background}${none}"
        "${yellow_background}${bold}     If prompted please enter your password!      ${yellow_background}${none}"
        "${yellow_background}${bold}                                                  ${yellow_background}${none}"
        "${yellow_background}${bold}    This is necessary to finish installation.     ${yellow_background}${none}"
        "${yellow_background}${bold}                                                  ${yellow_background}${none}"
    )
    
    local cols=$(tput cols)
    
    # Loop through each line and process it
    for line in "${lines[@]}"; do
    
        local title_length=50
        local left_padding=$(( (cols - title_length) / 2 ))

        local padding=$(printf "%*s" "$left_padding" | tr ' ' " ")
        
        local padded_line="${padding}${line}"
        
        message=$(cat <<EOF
$message
${padded_line}
EOF
)
    done

    center_message_input "$message" '#' '#' " " " Prerequisites " --no-input
    
    chmod -R +x "$INSTALL_DIR/ipatool"
    
    local last_line=$(ipatool auth info 2>&1 | tail -n 1)
    if [[ "$last_line" =~ "command not found" ]]; then
        echo -e "${lightred}${bold}Error: command not found: ipatool${none}"
        rm -rf "${HOME_DIR}/temp/bin"
        return 1
    fi
    return 0
}

install_jq() {
    INSTALL_DIR="/usr/local/bin"
    
    # Detect architecture
    ARCH=$(uname -m)
    if [[ "$ARCH" == "arm64" ]]; then
        BINARY_NAME="jq-macos-arm64"
    else
        BINARY_NAME="jq-macos-amd64"
    fi

    latest_url=$(curl -sL "https://api.github.com/repos/jqlang/jq/releases/latest" | grep -oE '"browser_download_url": ?"[^"]*'"${BINARY_NAME}"'"' | cut -d '"' -f 4)
    
    curl -L -o "$INSTALL_DIR/jq" "$latest_url"
    
    if [[ ! -f "${INSTALL_DIR}/jq" ]]; then
        echo -e "${lightred}${bold}Error: Extracted binary not found.${none}"
        rm -rf "${HOME_DIR}/temp/"
        return 1
    fi

    # Clean up
    rm -rf "${HOME_DIR}/temp/"
            
    local message=""
        
    local lines=(
        "${yellow_background}${bold}                                                  ${yellow_background}${none}"
        "${yellow_background}${bold}     If prompted please enter your password!      ${yellow_background}${none}"
        "${yellow_background}${bold}                                                  ${yellow_background}${none}"
        "${yellow_background}${bold}    This is necessary to finish installation.     ${yellow_background}${none}"
        "${yellow_background}${bold}                                                  ${yellow_background}${none}"
    )
    
    local cols=$(tput cols)
    
    # Loop through each line and process it
    for line in "${lines[@]}"; do
    
        local title_length=50
        local left_padding=$(( (cols - title_length) / 2 ))

        local padding=$(printf "%*s" "$left_padding" | tr ' ' " ")
        
        local padded_line="${padding}${line}"
        
        message=$(cat <<EOF
$message
${padded_line}
EOF
)
    done

    center_message_input "$message" '#' '#' " " " Prerequisites " --no-input
    
    chmod -R +x "$INSTALL_DIR/jq"
    
    local last_line=$(jq --version 2>&1)
    if [[ "$last_line" =~ "command not found" ]]; then
        echo -e "${lightred}${bold}Error: command not found: ipatool${none}"
        rm -rf "${HOME_DIR}/temp/bin"
        return 1
    fi
    
    return 0
}

check_for_dependencies() {
    local error_message=()
    while True; do
        local message=""
        local Need_to_install_ipatool="true"
        local Need_to_install_ipatool="true"
        local jq_colour=""
        local ipatool_colour=""
        local jq_spaces_left=""
        local jq_spaces_right=""
        local ipatool_spaces_left=""
        local ipatool_spaces_right=""
        local lines=()
        local hoembrew_ipatool="false"
        
        local last_line=$(jq --version 2>&1)

        if [[ "$last_line" =~ "command not found" ]]; then
        
            local jq_message="  jq - Needs to be installed  "
            
            Need_to_install_jq="true"
            
        else
        
            local jq_message="  jq - Installed  "
            
            Need_to_install_jq="false"
            
        fi
        
        local last_line=$(ipatool -v 2>&1 | tail -n 1)
        if [[ "$last_line" =~ "command not found" ]]; then
        
            local ipatool_message="  ipatool - Needs to be installed  "
            
            Need_to_install_ipatool="true"
            
        else
            local latest_ipatool=$(curl -s https://api.github.com/repos/majd/ipatool/releases/latest | grep '"tag_name":' | sed -E 's/.*"tag_name": ?"v?([^"]+).*/\1/')
            if [[ -n "$latest_ipatool" ]]; then
                if [[ "$last_line" =~ "$latest_ipatool" ]]; then

                    local ipatool_message="  ipatool - Installed  "
                
                    Need_to_install_ipatool="false"
                    
                else
                    local ipatool_message="  ipatool - Needs to be updated  "
                    
                    Need_to_install_ipatool="true"
                    if [[ -L "$INSTALL_DIR/ipatool" ]]; then
                       homebrew_ipatool="true"
                    fi
                fi
            else
            
                local ipatool_message="  ipatool - Installed  "
                
                Need_to_install_ipatool="false"
            fi
        fi
        
        #exit if both are installed
        if [ "$Need_to_install_jq" = "false" ] && [ "$Need_to_install_ipatool" = "false" ]; then
            break
        fi
        
        # jq
        while [ $(( ${#jq_message} + ${#jq_spaces_left} + ${#jq_spaces_right} )) -lt 54 ]; do
            # Append a character to the string (for demonstration)
            jq_spaces_left="${jq_spaces_left} "
            jq_spaces_right="${jq_spaces_right} "
        done
        
        while [ $(( ${#jq_message} + ${#jq_spaces_left} + ${#jq_spaces_right} )) -lt 55 ]; do
            # Append a character to the string (for demonstration)
            jq_spaces_right="${jq_spaces_right} "
        done
        
        if [ "$Need_to_install_jq" = "true" ]; then
            jq_colour="$red_background${bold}"
        else
            jq_colour="$green_background${bold}"
        fi
        
        #ipatool
        while [ $(( ${#ipatool_message} + ${#ipatool_spaces_left} + ${#ipatool_spaces_right} )) -lt 54 ]; do
            # Append a character to the string (for demonstration)
            ipatool_spaces_left="${ipatool_spaces_left} "
            ipatool_spaces_right="${ipatool_spaces_right} "
        done
        
        while [ $(( ${#ipatool_message} + ${#ipatool_spaces_left} + ${#ipatool_spaces_right} )) -lt 55 ]; do
            # Append a character to the string (for demonstration)
            ipatool_spaces_right="${ipatool_spaces_right} "
        done
        
        if [ "$Need_to_install_ipatool" = "true" ]; then
            ipatool_colour="$red_background${bold}"
        else
            ipatool_colour="$green_background${bold}"
        fi
        
        local lines=(
"${cyan_background}${bold}                                                       ${none}"
"${cyan_background}${bold}  The following commands are required for this script  ${none}"
"${cyan_background}${bold}    to function, but not all of them are installed.    ${none}"
"${cyan_background}${bold}                                                       ${none}"
"${cyan_background}${bold}${jq_spaces_left}${jq_colour}${jq_message}${cyan_background}${bold}${jq_spaces_right}${none}"
"${cyan_background}${bold}                                                       ${none}"
"${cyan_background}${bold}${ipatool_spaces_left}${ipatool_colour}${ipatool_message}${cyan_background}${bold}${ipatool_spaces_right}${none}"
"${cyan_background}${bold}                                                       ${none}"
"${cyan_background}${bold}  Press any key to install the missing dependencies.   ${none}"
"${cyan_background}${bold}                                                       ${none}"
)

        lines+=("${error_message[@]}")
    
        local cols=$(tput cols)
    
        # Loop through each line and process it
        for line in "${lines[@]}"; do
    
            local title_length=55
            local left_padding=$(( (cols - title_length) / 2 ))

            local padding=$(printf "%*s" "$left_padding" | tr ' ' " ")
        
            local padded_line="${padding}${line}"
        
        message=$(cat <<EOF
$message
${padded_line}
EOF
)
        done
    
        center_message_input "$message" '#' '#' "Press any key begin installation: " " Prerequisites "
        
        if "$Need_to_install_jq" = "true"; then
            install_jq
            if [ $? -eq 0 ]; then
                #worked
                error_message=()
            else
                error_message=(
""
"${red_background}${bold}                                                       ${none}"
"${red_background}${bold}                 jq failed to install                  ${none}"
"${red_background}${bold}                                                       ${none}"
)
                continue #restart while
            fi
        fi
        
        if "$Need_to_install_ipatool" = "true"; then
            if "$homebrew_ipatool" = "true"; then
                install_ipatool "homebrew"
            else
                install_ipatool
            fi
            
            if [ $? -eq 0 ]; then
                error_message=()
            else
                error_message=(
""
"${red_background}${bold}                                                       ${none}"
"${red_background}${bold}              ipatool failed to install                ${none}"
"${red_background}${bold}                                                       ${none}"
)
                continue
            fi
        fi
        
        ######dsiplay success
        
        message=""
        
        lines=(
"${green_background}${bold}                                                  ${green_background}${none}"
"${green_background}${bold}                      Success                     ${green_background}${none}"
"${green_background}${bold}                                                  ${green_background}${none}"
"${green_background}${bold}   All required dependencies are now installed.   ${padded_message}${green_background}${none}"
"${green_background}${bold}                                                  ${green_background}${none}"
    )
    
        local cols=$(tput cols)
    
        # Loop through each line and process it
        for line in "${lines[@]}"; do
    
            local title_length=50
            local left_padding=$(( (cols - title_length) / 2 ))

            local padding=$(printf "%*s" "$left_padding" | tr ' ' " ")
        
            local padded_line="${padding}${line}"
        
            message=$(cat <<EOF
$message
${padded_line}
EOF
)
        done
    
        center_message_input "$message" '#' '#' "Press Any Key To Continue: " " Prerequisites "
        break
    done
    
    check_ipatool
}

check_ipatool() {
    local last_line=$(ipatool download -b com 2>&1 | tail -n 1)
    while True; do
        if [[ "$last_line" =~ "failed to get account" ]] || [[ "$last_line" =~ "failed to reoslve the country code" ]]; then
        
            ipatool auth revoke
            
            center_message_input "${yellow}${bold}ipatool is installed but hasn't been configured.${none}


Press any key to configure it now.


Or do it yourself with: (ipatool auth login -e <your appleid>)
" '#' '#' "Press Any Key To Configure ipatool: " " Prerequisites "
            
            while True; do
                center_message_input "For ipatool to function it has to authenticate with the Appstore.
        
${purple}${bold}Enter your Apple ID email.${none}" '#' '#' "Apple ID Email: " " Prerequisites " --long
                local email="$choice"
    
                center_message_input "${purple}${bold}Enter your Apple ID password.${none}
        
        
${yellow_background}                                                           ${yellow_background}
${yellow_background}${bold}   Important!                                              ${yellow_background}
   If you get a message asking for keychain access,        ${yellow_background}
   choose \"Always Allow\". This is neccasary to securely    ${yellow_background}
   store your login in your mac keychain for later use.    ${yellow_background}
                                                           ${none}" '#' '#' "Apple ID Password: " " Prerequisites " --sensitive
                local password="$choice"
        
                ipatool auth login -e ${email} -p ${password}
        
                local last_line=$(ipatool download -b com 2>&1 | tail -n 1)
                if [[ "$last_line" =~ "failed to get account" ]] || [[ "$last_line" =~ "failed to reoslve the country code" ]]; then
                    ipatool auth revoke
                    center_message_input "${lightred}${bold}Your Apple ID email/password was incorrect.

Alternatively you either did not allow keychain access
or enter a 2FA code was not provided when prompted.${none}" '#' '#' "Press Any Key To Retry: " " Prerequisites "
                else
                    center_message_input "${lightgreen}${bold}ipatool was configured successfully.${none}" '#' '#' "Press Any Key To Continue: " " Prerequisites "
                    return
                fi
            done
        fi
        return
    done
}

# Check if this is first launch
if [ "$1" == "updated" ]; then
    updated
fi

#check if folder exists
if [ ! -d ~/InsaneAppPurchaser ]; then
    # Create the directory
    mkdir -p ~/InsaneAppPurchaser
    touch ~/InsaneAppPurchaser/enableLogging
fi

if [ ! -d ~/InsaneAppPurchaser/logs ]; then
    # Create the directory
    mkdir -p ~/InsaneAppPurchaser/logs
fi

check_for_dependencies
check_for_updates
main_menu
