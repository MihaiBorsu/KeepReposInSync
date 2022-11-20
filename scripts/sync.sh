#!/bin/bash

WORKSPACE="."

function is_modified() {
    git -C ${WORKSPACE} status | (
        unset dirty deleted untracked newfile ahead renamed
        while read line ; do
            case "$line" in
            *modified:*)                      dirty='!' ; ;;
            *deleted:*)                       deleted='x' ; ;;
            *'Untracked files:')              untracked='?' ; ;;
            *'new file:'*)                    newfile='+' ; ;;
            *'Your branch is ahead of '*)     ahead='*' ; ;;
            *renamed:*)                       renamed='>' ; ;;
            esac
        done
        bits="$dirty$deleted$untracked$newfile$ahead$renamed"
        echo "$bits"
        [ -n "$bits" ] && return true || return false
    )
}

function main() {
    set -x
    [[ $(is_modified) ]] && echo "modified"
    set +x
}

main