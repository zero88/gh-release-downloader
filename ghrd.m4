#!/bin/bash

VERSION=1.1.2

# m4_ignore(
echo "This is just a script template, not the script (yet) - pass it to 'argbash' to fix this." >&2
exit 11  #)Created by argbash-init v2.10.0
# ARG_OPTIONAL_SINGLE([release], r, [A release version], [latest])
# ARG_OPTIONAL_SINGLE([pat], t, [GitHub Personal access token])
# ARG_OPTIONAL_SINGLE([artifact], a, [Artifact name])
# ARG_OPTIONAL_BOOLEAN([regex], x, [Use regex to search artifact], [off])
# ARG_OPTIONAL_SINGLE([parser], p, [Use custom jq parser instead of search by artifact name])
# ARG_OPTIONAL_SINGLE([source], s, [Download Repository Source instead of release artifact], [])
# ARG_OPTIONAL_SINGLE([output], o, [Downloaded directory], [$(pwd)])
# ARG_OPTIONAL_BOOLEAN([debug], , [Debug option], [off])
# ARG_TYPE_GROUP_SET([sources], [SOURCE], [source], [zip,tar,], [index])
# ARG_POSITIONAL_SINGLE([repo], [GitHub repository. E.g: zero88/gh-release-downloader])
# ARGBASH_SET_DELIM([ =])
# ARG_OPTION_STACKING([getopt])
# ARG_RESTRICT_VALUES([no-local-options])
# ARG_DEFAULTS_POS
# ARG_HELP([<GitHub release downloader>])
# ARG_VERSION([echo $0 v$VERSION])
# ARGBASH_GO

# [ <-- needed because of Argbash

# vvv  PLACE YOUR CODE HERE  vvv
# ------------------------------

set -e

NC='\033[0m'       #]
RED='\033[0;31m'   #]
GREEN='\033[32m'   #]
YELLOW='\033[33m'  #]
BLUE='\033[34m'    #]
function error() {
    echo -e "$RED$1$NC"
}

function progress() {
    echo -e "$BLUE$1$NC"
}

function success() {
    echo -e "$GREEN$1$NC"
}

function debug() {
    echo -e "$YELLOW$1$NC"
}

function create_parser() {
    if [[ -n $_arg_source ]]; then
        echo "."
    elif [[ -n $_arg_parser ]]; then
        echo "$_arg_parser"
    else
        local jq_test=""
        [[ $_arg_regex == "on" ]] && jq_test=".name|test(\"$_arg_artifact\"; \"il\")" || jq_test=".name == \"$_arg_artifact\""
        echo ".assets | map(select($jq_test))[0]"
    fi
}

function make_download_url() {
    if [[ -z $_arg_source ]]; then
        echo "$BASE_URL/assets/$1"
    elif [[ $_arg_source == 'zip' ]]; then
        jq -r '.zipball_url' <<< "$1"
    elif [[ $_arg_source == 'tar' ]]; then
        jq -r '.tarball_url' <<< "$1"
    fi
}

function guess_artifact_name() {
    if [[ -z $_arg_source ]]; then
        jq -r '.name' <<< "$1"
    else
        local tag=$(jq -r '.tag_name' <<< "$1")
        local ext="zip"
        [[ $_arg_source == "tar" ]] && ext="tar.gz"
        echo "${_arg_repo/\//-}-$tag.$ext"
    fi
}


BASE_URL="https://api.github.com/repos/$_arg_repo/releases"
[[ $_arg_release != "latest" ]] && RELEASE_PATH="tags/$_arg_release" || RELEASE_PATH="$_arg_release"
[[ -z $_arg_pat ]] && AUTH_HEADER="" || AUTH_HEADER="Authorization: Bearer $_arg_pat"

progress "Searching release '$_arg_release' in repository '$_arg_repo'..."
OUT=/tmp/ghrd-$(LC_CTYPE=C tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 8 | head -n 1).json
HEADERS=( "Accept: application/vnd.github.v3+json" )
[[ -n $AUTH_HEADER ]] && HEADERS+=( "$AUTH_HEADER" )

STATUS=$(curl "${HEADERS[@]/#/-H}" -sL -w "%{http_code}" -o "$OUT" "$BASE_URL/$RELEASE_PATH")
if [[ ! "$STATUS" =~ ^2[[:digit:]][[:digit:]] ]]; then
    debug "$(<"$OUT")"; rm -rf "$OUT";
    error "Unable found release '$_arg_release' in repository '$_arg_repo'."
    error "HTTP status: $STATUS";
    exit 1;
fi

r=$(jq "$(create_parser)" < "$OUT")
[[ -z $_arg_source ]] && ARTIFACT_ID=$(jq -r '.id' <<< $r) || ARTIFACT_ID=$r
ARTIFACT_NAME=$(guess_artifact_name "$r")
DOWNLOAD_URL=$(make_download_url "$ARTIFACT_ID")

[[ $_arg_debug == "off" ]] && rm -rf "$OUT"
[[ $_arg_debug == "on" ]] && debug "HTTP Response is dump at $OUT"

[[ -z $ARTIFACT_ID ]] || [[ $ARTIFACT_ID == null ]] && { error "Not Found artifact '$_arg_artifact' with regex option '$_arg_regex'"; exit 2; }
success "Found artifact '$ARTIFACT_NAME' in '$_arg_repo:$_arg_release'."

HEADERS=()
[[ -z $_arg_source ]] && HEADERS+=( "Accept: application/octet-stream" )
[[ -n $AUTH_HEADER ]] && HEADERS+=( "$AUTH_HEADER" )
OUT="$_arg_output/$ARTIFACT_NAME"

echo
progress "Downloading '$ARTIFACT_NAME' to '$_arg_output'..."
STATUS=$(curl "${HEADERS[@]/#/-H}" -L -w "%{http_code}" -o "$OUT" "$DOWNLOAD_URL")
if [[ ! "$STATUS" =~ ^2[[:digit:]][[:digit:]] ]]; then
    debug "$(<"$OUT")"; rm -rf "$OUT";
    error "Unable download artifact '$ARTIFACT_NAME'.";
    error "HTTP status: $STATUS";
    exit 3;
fi
echo "--------------------------------------------------------------------------------"
echo "File: $(ls -lh $OUT | awk '{print $9 " " $5}')"
success "Finish!!!"

# ^^^  TERMINATE YOUR CODE BEFORE THE BOTTOM ARGBASH MARKER  ^^^

# ] <-- needed because of Argbash
