#!/bin/bash

WORKSPACE="."
REMOTE_NAME="origin"
SYNC_BRANCH="main"

function sync_only() {
    echo "only syncing..."
    git -C ${WORKSPACE} reset --hard ${REMOTE_NAME}/${SYNC_BRANCH}
}

function sync_and_push() {
    echo "will create a new commit"
    git -C ${WORKSPACE} stash
    git -C ${WORKSPACE} reset --hard ${REMOTE_NAME}/${SYNC_BRANCH}
    git -C ${WORKSPACE} stash pop
    git -C ${WORKSPACE} add ${WORKSPACE}/*
    git -C ${WORKSPACE} commit -m "auto created commit to sync repos"
    git -C ${WORKSPACE} push -f ${REMOTE_NAME} ${SYNC_BRANCH}
}

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
    [[ $(is_modified) ]] && sync_and_push || sync_only
}

main $@