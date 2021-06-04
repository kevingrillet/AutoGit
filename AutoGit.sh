#!/bin/bash
# https://www.shellcheck.net/

# https://gist.github.com/vratiu/9780109
NC='\033[0m'
RED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
WHITE='\033[1;37m'
IFS=$'\n'

# variables
DOALLBRANCHES=false
LOG=false
REPOSITORIES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VERBOSE=false

# usage
function usage {
  echo -e "AutoGit - Update every git repo"
  echo
  echo -e "Usage: AutoGit ${YELLOW}[options]${NC}"
  echo
  echo -e "Options:"
  echo -e "   ${YELLOW}-h                ${NC}Show usage"
  echo -e "   ${YELLOW}-v                ${NC}Verbose"
  echo -e "   ${YELLOW}-a                ${NC}Update every branches"
  echo -e "   ${YELLOW}-l                ${NC}Store version in csv to compare in next update"
  echo -e "                     ${NC}Output: log.csv"
  echo -e "   ${YELLOW}-d <DIRECTORY>    ${NC}Path to remote directory folder"
  echo -e "                     ${NC}Default: script folder"
}

# log <REPO> <BRANCH> <VERSION>
#VERSION=cut -d- -f1 <<< "$3"
function log {
  if [ $LOG = true ]; then
    echo "$1,$2,$3" >> "$REPOSITORIES/temp.csv"
  fi
}

# log_update
# logic to compare and print the log
function log_update {
  if [ $LOG = true ]; then
    if [ -f "$REPOSITORIES/temp.csv" ]; then
      if [ -f "$REPOSITORIES/log.csv" ]; then
        while read -r line ; do
          found=$(grep "${line%,*}" "$REPOSITORIES/log.csv")
          if [ -z "$found" ]; then
            echo -e "add,$line"
          else
            if [ "${found##,*}" = "${line##,*}" ]; then
              echo -e ",$line"
            else
              echo -e "update,$line"
            fi
          fi
          # https://www.putorius.net/column-command-usage-examples.html
        done < "$REPOSITORIES/temp.csv" | column -s"," -t -N STATUS,REPO,BRANCH,TAG -R TAG
        # https://stackoverflow.com/questions/20151601/color-escape-codes-in-pretty-printed-columns
        # WIP: not working properly atm :/
        # | echo -e "$(sed -e "s/add/${GREEN}add${NC}/g" -e "s/update/${RED}update${NC}/g")"

        my_exec mv "$REPOSITORIES/temp.csv" "$REPOSITORIES/log.csv"
      else
        echo -e "${YELLOW}Create log.csv${NC}"
        my_exec mv "$REPOSITORIES/temp.csv" "$REPOSITORIES/log.csv"
        column -s"," -t -N REPO,BRANCH,TAG -R TAG "$REPOSITORIES/log.csv"
      fi
    else
      echo -e "${RED}No temp.csv found.${NC}"
    fi
  fi
}

# my_exec <COMMAND>
# hide the output if verbose is false
function my_exec {
  if [ $VERBOSE = true ]; then
    "$@"
  else
    "$@" &>/dev/null
  fi
}

# pause
function pause {
  read -s -r -n 1 -p "Press any key to continue..."
  echo ""
}

# output
# echo if verbose
function output {
  if [ $VERBOSE = true ]; then
    echo -e "$1"
  fi
}

# update_branch <BRANCH>
# if remote exists > checkout
# then if status --porcelain > pull
# then log
function update_branch {
  LOCAL_BRANCH=$2
  output "${BLUE}Updating branch ${WHITE}$LOCAL_BRANCH ${NC}"
  if [ -n "$(git ls-remote origin "$LOCAL_BRANCH")" ]; then
    my_exec git checkout "$BRANCH"
    output "${GREEN}git status${NC}"
    my_exec git status
    if [ -z "$(git status --porcelain)" ]; then
      output "${GREEN}git pull${NC}"
      my_exec git pull
    fi
    if [ -n "$(git tag)" ]; then
      output "${GREEN}git describe --tag${NC}"
      my_exec git describe --tag
      log "$1" "$2" "$(git describe --tag)"
    else
      log "$1" "$2" "no tag"
    fi
  else
    log "$1" "$2" "no remote"
    output "${YELLOW}Skipping because it doesn't look like it has a remote branch.${NC}"
  fi
  output "${BLUE}Done${NC}"
}

while getopts ":ad:hlv" option ;
do
  case $option in
    a)
      DOALLBRANCHES=true
      ;;
    d)
      REPOSITORIES="$( cd "$OPTARG" && pwd )"
      ;;
    h)
      usage
      exit 1
      ;;
    l)
      LOG=true
      ;;
    v)
      VERBOSE=true
      ;;
    :)
      echo -e "${YELLOW}Argument required by this option: $OPTARG ${NC}"
      exit 1
      ;;
    \?)
      echo -e "${RED}$OPTARG : Invalid option${NC}"
      exit 1
      ;;
  esac
done

for REPO in $(ls "$REPOSITORIES/")
do
  if [ -d "$REPOSITORIES/$REPO" ]; then
    echo -e "${BLUE}Updating folder ${WHITE}$REPOSITORIES/$REPO${BLUE} at ${RED}$(date)${NC}"
    if [ -d "$REPOSITORIES/$REPO/.git" ]; then
      cd "$REPOSITORIES/$REPO" || exit
      output "${GREEN}git fetch --all --prune --prune-tags${NC}"
      my_exec git fetch --all --prune --prune-tags
      CURRENT_BRANCH=$(git branch --show-current)
      if [ $DOALLBRANCHES = true ]; then
        for BRANCH in $(git branch --format='%(refname:short)')
        do
          update_branch "$REPOSITORIES/$REPO" "$BRANCH"
        done
        my_exec git checkout "$CURRENT_BRANCH"
      else
        update_branch "$REPOSITORIES/$REPO" "$CURRENT_BRANCH"
      fi
    else
     output "${YELLOW}Skipping because it doesn't look like it has a .git folder.${NC}"
    fi
    echo -e "${BLUE}Done at ${RED}$(date)${NC}"
    echo
  fi
done

log_update

pause
