#!/bin/bash
# shellcheck source=/dev/null
# shellcheck disable=SC2068
set -e

C_GREEN="\\033[32m"
C_BLUE="\\033[34m"
C_REG="\\033[0;39m"

custom_straps=""
auto_approve=""
repo_location="https://raw.githubusercontent.com/azohra/strapped/master/straps"
yml_location="https://raw.githubusercontent.com/azohra/strapped/master/yml/first_run.yml"
url_regex='^(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]$'

pretty_print () {  
    local key
    local value
    key=${1}
    value=${2}
    echo -e "\\n${C_GREEN}${key}:${C_BLUE} ${value} ${C_REG}"
}

function usage {
    echo -e "\\nUsage: strapped [flags]\\n"
    echo "flags:"
    echo "  -u, --upgrade               upgrade strapped to the latest version"
    echo "  -v, --version               print the current strapped version"
    echo "  -a, --auto                  do not prompt for confirmation"
    echo "  -y, --yml file/url          path to a valid strapped yml config"
    echo "  -s, --straps string         run a subset of your config. Comma seperated."
    echo "  -h, --help                  prints this message"
    exit 1
}

function upgrade {
    rm /usr/local/bin/strapped
    curl -s https://stay.strapped.sh | sh
    pretty_print "Strapped: " "🔫 Upgraded Successfully!"
    exit 0
}

while [ $# -gt 0 ] ; do
    case "$1" in
    -u|--upgrade)
        upgrade
    ;;
    -y|--yml)
        yml_location="$2"
        shift # extra value 
    ;;
    -r|--repo)
        repo_location="$2"
        shift # extra value 
    ;;
    -s|--straps)
        custom_straps="$2"
        shift # extra value 
    ;;
    -a|--auto)
        auto_approve="true"
    ;;
    -v|--version)
        echo 'v0.1' && exit 0
    ;;
    -h|--help)
        usage
    ;;
    -*)
        "Unknown option: '$1'"
    ;;
    esac
    shift
done

# TODO: Load the parser from raw github url
init_parser() {
    parser=$(cat parser.awk)
}

# Query API
q() {
    grep -E "$2" <<< "$1" | sed 's/^.*=//'
}

q_sub() {
    grep -E "$2" <<< "$1" | sed "s/^$2//"
}

q_count() {
    q "$1" "$2" | wc -l
}

# Helper for config
q_config() {
    q "$json" "$1" | sed 's/^.*=//'
}

q_config_sub() {
    grep -E "$1" <<< "$json" | sed "s/^$1//"
}

parse_config() {
    # Check for YML
    if [[ "${yml_location}" =~ ${url_regex} ]]; then json=$(curl -s "${yml_location}" | awk "$parser"); else json=$(awk "$parser" "${yml_location}"); fi
    if [ ! "${json}" ]; then pretty_print "Strapped:" "Config not found" && exit 2;else pretty_print "Using Config From:" "${yml_location}"; fi
}

parse_strapped_repo() {
    # Check for Repo
    if [ "$(q_config "strapped.repo")" != "null" ]; then repo_location="$(q_config "strapped.repo")"; fi
    if [ ! "${repo_location}" ]; then pretty_print "Strapped:" "Repo not found" && exit 2;else pretty_print "Using Straps From:" "${repo_location}"; fi
}

create_strap_array() {
    # Create Strap Array
    if [[ "${custom_straps}" ]]; then straps="${custom_straps//,/ }"; else straps=$(q_config_sub "^" | sed "s/\\..*$//" | uniq); fi
    straps=${straps/strapped /}
    if [ ! "${straps}" ]; then pretty_print "Strapped:" "Straps not found" && exit 2;else pretty_print "Requested Straps: " "${straps}"; fi
}


ask_permission () {  
    local message
    message=${1}
    pretty_print "Question:" "${message}"
    printf "(Y/N): "
    while true
    do
      if [ "${auto_approve}" ]; then ans="y" && printf "Y (auto)"; else read -r ans; fi
      case ${ans} in
       [yY]* ) break;;
       [nN]* ) exit;;
       * )     printf "Y/N: ";;
      esac
    done
}

stay_strapped () {    
    for strap in ${straps}; do
        if [[ ${repo_location} =~ ${url_regex} ]]; then
            source /dev/stdin <<< "$(curl -s "${repo_location}/${strap}/${strap}.sh")"
        else
            source "${repo_location}/${strap}/${strap}.sh"
        fi
        strap_json=$(q_config_sub "${strap}\\.")
        echo -e "\\n${C_GREEN}Strap: ${C_BLUE}${strap}${C_REG}"
        strapped_"${strap}"_before "${strap_json}"
        strapped_"${strap}" "${strap_json}"
        strapped_"${strap}"_after "${strap_json}"
    done
}

init_parser
parse_config
parse_strapped_repo
create_strap_array
ask_permission "Are you ready to get strapped?"
stay_strapped
