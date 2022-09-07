#!/bin/sh
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

###
# START global variables
###

M3OPASS_VERSION=0.1.1

# Create command variables
M3OPASS_CREATE_PASS_LENGTH=16

###
# END global variables
###

###
# START usage messages
###

m3opass_print_usage() {
    echo "usage: m3opass COMMAND [ OPTS... ] [ ARG ]"
    echo
    echo "Available commands:"
    echo "  create      Create a new password"
    echo "  help        Print this help message"
    echo "  get         Get a stored password"
    echo "  store       Store a new password"
    echo "  version     Display m3opass version"
    echo
    echo "Run \`m3popass COMMAND help' to print command-specific help messages"
}

m3opass_print_create_usage() {
    echo "usage: m3opass create [ OPTS ]"
    echo
    # @TODO: Implement -l, --length / -s, --store functionalities
    # echo "Available options:"
    # echo "  -l, --length <int>    Generate password length of <int> length"
    # echo "                         Default length: 16"
    # echo
    echo "  -q, --quiet            Only print the generated password"
    echo "                          Omit -s, --store to print the new password to stdard output"
    # echo
    # echo "  -s, --store <str>     Store password with a name of <str>"
}

###
# END usage messages
###

###
# START helper functions
###

m3opass_check_env() {
    [ -z "$M3O_API_TOKEN" ] \
        && echo "\$M3O_API_TOKEN is unset, please set your M3O token, e.g. \`export M3O_API_TOKEN=<TOKEN>'" \
        && exit 1
}

m3opass_parse_create_opts() {
    for opt in "$@"; do
        case "$opt" in
            -q|--quiet) M3OPASS_CREATE_QUIET=1 ;;
        esac
    done
}

m3opass_service_fetch() {
    curl "https://api.m3o.com/v1/${m3o_service}"        \
        --silent                                        \
        --header "Content-Type: application/json"       \
        --header "Authorization: Bearer $M3O_API_TOKEN" \
        --data "$m3o_service_data" | tee
}

###
# END helper functions
###

###
# START m3opass command functions
###

m3opass_create_pass() {
    [ "$#" -lt 1  ] && m3opass_print_create_usage && exit 1
    [ "$2" = help ] && m3opass_print_create_usage && exit 0
    m3opass_parse_create_opts "$@"

    m3o_service="password/Generate"
    m3o_service_data="{\"length\": ${M3OPASS_CREATE_PASS_LENGTH}}"

    generated_password=$(m3opass_service_fetch "$m3o_service" "$m3o_service_data" \
        | jq .password \
        | sed 's/"//g')

    [ -z "$M3OPASS_CREATE_QUIET" ] \
        && echo "Generated password: ${generated_password}" \
        || echo "$generated_password"
}
    

###
# END m3opass command functions
###

main() {
    # Check to see if we have at least one argument, which is the minimum required
    [ ! $# -gt 0 ] && m3opass_print_usage && exit 1
    [ "$1" = help ] && m3opass_print_usage && exit 0
    m3opass_check_env

    # Handle the m3opass command supplied by the user
    case "$1" in
        create)  m3opass_create_pass "$@"                ;;
        get)     echo "Feature is a work in progress..." ;;
        set)     echo "Feature is a work in progress..." ;;
        version) echo "$M3OPASS_VERSION"                 ;;
        *)       m3opass_print_usage && exit 1           ;;
    esac

    exit 0
}

main "$@"
