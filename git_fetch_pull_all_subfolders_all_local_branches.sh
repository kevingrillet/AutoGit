#!/bin/bash

# Fonctionnement:
#   Sans paramètre s'exécute pour le répertoire courant.
#   Avec paramètre s'exécute pour le répertoire passé en paramètre.
#
#   Regarde si les sous-dossiers sont des repo.
#   Si oui: fetch puis pull si pas de modification en attente
#   toutes les branches locales.
# 
# Exemples:
#   Placer le fichier dans [PATH] et double clic dessus.
#
#   Dans la console, se placer dans le répertoire du script et exécuter:
#  .\git_fetch_pull_all_subfolders_all_local_branches.sh [PATH]

NC='\033[0m'
RED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
WHITE='\033[1;37m'
IFS=$'\n'

function pause(){
  read -s -n 1 -p "Press any key to continue..."
  echo ""
}

if [[ -z "$1" ]]
then
   REPOSITORIES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
else
   REPOSITORIES="$( cd "$1" && pwd )"
fi

for REPO in `ls "$REPOSITORIES/"`
do
  if [ -d "$REPOSITORIES/$REPO" ]
  then
    echo -e "${BLUE}Updating folder ${WHITE}$REPOSITORIES/$REPO${BLUE} at ${RED}`date`${NC}"
    if [ -d "$REPOSITORIES/$REPO/.git" ]
    then
      cd "$REPOSITORIES/$REPO"
      echo -e "${GREEN}git fetch --all${NC}"
      git fetch --all
      CURRENT_BRANCH=`git branch --show-current`
      for BRANCH in `git branch --format='%(refname:short)'`
      do
        echo -e "${BLUE}Updating branch ${WHITE}${BRANCH} ${NC}"
        git checkout "${BRANCH}"
        echo -e "${GREEN}git status${NC}"
        git status
        if [[ -z "$(git status --porcelain)" ]]
        then
          echo -e "${GREEN}git pull${NC}"
          git pull
        fi
        echo -e "${GREEN}git describe --tag${NC}"
        git describe --tag
        echo -e "${BLUE}Done${NC}"
      done
      git checkout "$CURRENT_BRANCH" 
    else
      echo -e "${YELLOW}Skipping because it doesn't look like it has a .git folder.${NC}"
    fi
    echo -e "${BLUE}Done at ${RED}`date`${NC}"
    echo
  fi
done
pause
