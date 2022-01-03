#!/usr/bin/env bash
#
# Author:        Mauro Medda < medda.mauro at gmail dot com >
#
# Date:          Sun Jan  2 12:23:17 +04 2022
#
# Prerequisite:
#
# Release:       v1.0.0
#
# ChangeLog:     v1.0.0 - Initial release
#
# Purpose:       Configure your GitHub Account within git.
#

### TODO ###


trap "echo ERROR: There was an error in ${FUNCNAME-main context}, details to follow" ERR

#
# General script behavior
#
set -euo pipefail
#set -n
#set -x

#
# Veriables
#
script=${0##*/}
thishost=$(hostname | cut -d\. -f1-3)
today=$(date +%Y%m%d)
thishost=$(hostname | cut -d\. -f1-3)
GIT=/usr/bin/git

#
# Tput options
#
bold=$(tty -s && tput bold)
high=$(tty -s && tput smso)
unde=$(tty -s && tput smul)
norm=$(tty -s && tput sgr0)
hidden='\e[8m'
black='\E[30;47m'
invert='\e[7m'
red='\e[31m'
redb='\e[41m'
lred='\e[91m'
lredb='\e[101m'
green='\e[32m'
blue='\e[34m'
blueb='\e[44m'
lblueb='\e[104m'
cyan='\e[36m'
cyanb='\e[46m'

#
# Functions
#

## Log function
Log() {
    message=$(echo -e ${1} | sed -e "s,(,\\\(,g" -e "s,),\\\),g")

    if [[ -z "${message}" ]]; then
        eval echo -e "\$(date '+%h %d %H:%M:%S') ${thishost} ${script}[$$]: no message provided"
      else
        eval echo -e "$(date '+%h %d %H:%M:%S') ${thishost} ${script}[$$]: ${message}"
    fi
}

## Rosetta 2 Installer function
function install_rosetta2() {
  sudo softwareupdate --install-rosetta
  if (($?)); then
    Log "ERROR: [BREW] Rosetta2 installation failed" && exit 100
  fi 
}
## Github CLI installer function
function install_github(){
  install_rosetta2
  brew install gh
  brew tap microsoft/git
  brew install --cask git-credential-manager-core
  if (($?)); then
    Log "ERROR: [BREW] GH installation failed" && exit 101
  fi
}

## Installation summary function
function summary() {
  cat <<__SUMMARY__
  Your laptop has been DevOps-tized. You have all the required tools
  to perform your day to day DevOps/SRE activities installed and configured.

  The script installed:
  - Rosetta 2
  - git-credential-manager-core
  - GitHub CLI aka gh

  For Further informations, refer to:
    -> https://docs.github.com/en/get-started/getting-started-with-git
    -> https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent
    -> https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account

  Example:

  ## Generate a new SSH key
  $ ssh-keygen -t ecdsa-sha2-nistp521

  ## Refresh GitHub authentication
  $ gh auth refresh -h github.com -s admin:public_key

  ## Add the Key to your GitHub account
  $ gh ssh-key add .ssh/id_ecdsa.pub --title "mauro - personal laptop"

  ## Test the connectivity
  $ ssh -T git@github.com

__SUMMARY__
}

#
# MAIN
#
install_github              # Install GitHub CLI.
summary                     # Show the installation summary.
