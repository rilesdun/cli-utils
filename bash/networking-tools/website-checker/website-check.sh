#!/bin/bash

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
RESET="$(tput sgr0)"

function help() {
    echo "Usage: $0 COMMAND"
    echo
    echo "Commands: 
    test-websites - Checks http status of website list in websites.txt
    json-api - Returns HTTP response and API response (if any) from apis.txt"
    exit
}

function msg () {
    #usage: msg [color] message status_code 
    if [[ "$#" -eq 0 ]]; then echo ""; return; fi;
    _status_code_color=""
    if [[ ! -z "$3" ]]; then
        case "$3" in
            2*|3*) _status_code_color="${GREEN}";;
            403) _status_code_color="${YELLOW}";;
            404) _status_code_color="${RED}";;
            *) _status_code_color="${RED}";;
        esac
    fi

    _msg="[$(date +'%Y-%m-%d %H:%M:%S %Z')] ${2//\$\{http_status\}/$_status_code_color${3}${RESET}}"
    case "$1" in
        [Yy]*) echo -e "${YELLOW}${_msg}${RESET}";;
        [Rr]*) echo -e "${RED}${_msg}${RESET}";;
        [Gg]*) echo -e "${GREEN}${_msg}${RESET}";;
        * ) echo -e "${_msg}";;
    esac
}

function test-websites() {
    websites_file="websites.txt"

    while read -r website || [[ -n "${website}" ]]; do

        if [[ -z "${website}" ]]; then
            continue
        fi
        #send curl to check http status, stdout directed to null, storing http code
        #curl follows redirects
        http_status=$(curl -L -o /dev/null -s -w "%{http_code}" "https://${website}")

        # custom messages depending on http status code
        case $http_status in
            2*)
                msg green "Website ${website} is available (HTTP status: ${http_status})"
                ;;
            301)
                msg red "website ${website} has been moved permanently (HTTP status: ${http_status})"
                ;;
            403)
                msg yellow "Website ${website} is forbidden to check (HTTP status: ${http_status})"
                ;;
            404)
                msg red "Website ${website} is unreachable (HTTP status: ${http_status})"
                ;;
            5*)
                msg red "API ${api_endpoint} responded with server error response (HTTP status: ${http_status})"
                ;;
            *)
                msg red "Website ${website} is not available (HTTP status: ${http_status})"
                ;;
        esac
    done < "${websites_file}"
}

function json-api() {
    apis_file="apis.txt"
    while read -r api_endpoint; do
        #example post request for peerplays api
        response=$(curl -X POST -s -o - -w "%{http_code}" -H "Content-Type: application/json" -d '{"jsonrpc": "2.0", "method": "get_chain_properties", "params": [], "id": 1}' "${api_endpoint}")
        http_status=${response: -3}
        api_response=${response:0:-3}

    case $http_status in
        2*)
            msg green "API ${api_endpoint} responded successfully (HTTP status: ${http_status})"
            parsed_response=$(echo "$api_response" | jq)
            echo "API Response: $parsed_response"
            ;;

        301)
            msg red "API ${api_endpoint} has been moved permanently (HTTP status: ${http_status})"
            ;;
        403)
            msg yellow "API ${api_endpoint} access is forbidden (HTTP status: ${http_status})"
            ;;
        404)
            msg red "API ${api_endpoint} is unreachable (HTTP status: ${http_status})"
            ;;
        5*)
            msg red "API ${api_endpoint} responded with server error response (HTTP status: ${http_status})"
            ;;

        *)
            msg red "API ${api_endpoint} responded with an error (HTTP status: ${http_status})"
            ;;
    esac
done < "${apis_file}"
}

if [[ -z "$1" ]]; then
    test-websites
else
    case $1 in
        test-websites)
            msg yellow "Consider updating your websites.txt"
            test-websites
            ;;
        json-api)
            msg yellow "Consider updating your apis.txt"
            json-api
            ;;
        *)
            msg red "Invalid cmd"
            help
            ;;
    esac
fi
