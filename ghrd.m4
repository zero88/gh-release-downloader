#!/bin/bash

VERSION=1.0.0

# m4_ignore(
echo "This is just a script template, not the script (yet) - pass it to 'argbash' to fix this." >&2
exit 11  #)Created by argbash-init v2.10.0
# ARG_OPTIONAL_SINGLE([release], r, [A release version], [latest])
# ARG_OPTIONAL_SINGLE([pat], t, [GitHub Personal access token])
# ARG_OPTIONAL_SINGLE([artifact], a, [Artifact name])
# ARG_OPTIONAL_BOOLEAN([regex], , [Use regex to search artifact], [off])
# ARG_OPTIONAL_SINGLE([parser], p, [Use custom jq parser])
# ARG_OPTIONAL_SINGLE([output], o, [Download directory], [$(pwd)])
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

RED='\033[0;31m'  #]
NC='\033[0m'      #]
GREEN='\033[32m'  #]
YELLOW='\033[33m'   #]
function error() {
    echo -e "$RED$1$NC"
}

function progress() {
    echo -e "$YELLOW$1$NC"
}

function success() {
    echo -e "$GREEN$1$NC"
}

BASE_URL="https://api.github.com/repos/$_arg_repo/releases"

[[ $_arg_release != "latest" ]] && RELEASE_PATH="tags/$_arg_release" || RELEASE_PATH="$_arg_release"

[[ -z $_arg_pat ]] && AUTH_HEADER="" || AUTH_HEADER="Authorization: Bearer $_arg_pat"

[[ $_arg_regex == "on" ]] && JQ_CHECK=".name|test(\"$_arg_artifact\"; \"il\")" || JQ_CHECK=".name == \"$_arg_artifact\""
[[ -z $_arg_parser ]] && PARSER=".assets | map(select($JQ_CHECK))[0]" || PARSER="$_arg_parser"

progress "Searching release '$_arg_release' in repository '$_arg_repo'..."
OUT=/tmp/ghrd-$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 8 | head -n 1).json
HEADERS=( "Accept: application/vnd.github.v3+json" )
[[ -z $AUTH_HEADER ]] || HEADERS+=("$AUTH_HEADER")

STATUS=$(curl "${HEADERS[@]/#/-H}" -sL -w "%{http_code}" -o "$OUT" "$BASE_URL/$RELEASE_PATH")
if [[ ! "$STATUS" =~ ^2[[:digit:]][[:digit:]] ]]; then
    cat "$OUT";
    error "Unable found release '$_arg_release' in repository '$_arg_repo'."
    error "HTTP status: $STATUS";
    exit 1;
fi

r=$(jq "$PARSER" < "$OUT")
aId=$(echo "$r" | jq -r '.id')
aName=$(echo "$r" | jq -r '.name')
[[ -z $aId ]] || [[ $aId == null ]] && { error "Not Found artifact '$_arg_artifact' with regex option '$_arg_regex'"; exit 2; }
success "Found artifact '$aName' with id: '$aId'."

HEADERS=( "Accept: application/octet-stream" )
OUT="$_arg_output/$aName"
[[ -z $AUTH_HEADER ]] || HEADERS+=("$AUTH_HEADER")

progress "Downloading '$aName' to '$_arg_output'..."
echo
STATUS=$(curl "${HEADERS[@]/#/-H}" -L -w "%{http_code}" -o "$OUT" "$BASE_URL/assets/$aId")
if [[ ! "$STATUS" =~ ^2[[:digit:]][[:digit:]] ]]; then
    error "Unable download artifact '$aName'.";
    error "HTTP status: $STATUS";
    exit 3;
fi
echo "--------------------------------------------------------------------------------"
echo "File: $(ls -lh $OUT | awk '{print $9 " " $5}')"
success "Finish!!!"

# ^^^  TERMINATE YOUR CODE BEFORE THE BOTTOM ARGBASH MARKER  ^^^

# ] <-- needed because of Argbash
