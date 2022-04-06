#!/usr/bin/env bash
#
# Author:        Mauro Medda < medda.mauro at gmail dot com >
#
# Date:          Mon Dec 27 18:39:23 +04 2021
#
# Prerequisite:
#
# Release:       v1.0.0
#
# ChangeLog:     v1.0.0 - Initial release
#
# Purpose:       Setup a MacOS based DevOps workstation from the ground-up with
#                a click of a button.
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
BREW=/opt/homebrew/bin/brew
brew_packages=( git zsh-syntax-highlighting kubectl
kubectx minikube helm ansible terraform awscli jq
go k9s terragrunt pre-commit graphviz)
brew_cask_packages=( visual-studio-code docker )

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

## Install brew tool function
function install_brew() {
  rc=$(/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" &> /dev/null ; echo $?)
  if [[ ${rc} -ne 0 ]]; then
    Log "FATAL: brew installation failed, abort" && exit 2
  fi
}

## Brew packages installer function
function brew_install() {
  rc=$(${BREW} install $1 &> /dev/null ; echo $?)
  if [[ ${rc} -ne 0 ]]; then
    Log "ERROR: [BREW] package ${1} installation failed" && exit 100
  fi
}

## Brew cask packages installer function
function brew_cask_install() {
  rc=$(${BREW} install --cask $1 &> /dev/null ; echo $?)
  if [[ ${rc} -ne 0 ]]; then
    Log "ERROR: [BREW_CASK] package ${1} installation failed" && exit 100
  fi
}

## VIM configuration function
function config_vim() {
  cat <<-_CONFIG_VIM_ | sed 's/        //' >> ${HOME}/.vimrc
        syntax on
        set ruler
        set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
_CONFIG_VIM_
}

## ZSH Configuration function
function config_zsh() {
  if [[ -f ${HOME}/.zshrc ]]; then
    if ! grep -q anoster ${HOME}/.zshrc ; then
      echo ZSH_THEME="agnoster" >> ${HOME}/.zshrc
    fi
  fi
  echo ZSH_THEME="agnoster" >> ${HOME}/.zshrc
}

## Brew base dependencies installer function
function install_brew_deps() {
  for pkg in "${brew_packages[@]}"; do
    brew_install $pkg
  done
}

## Brew cask dependencies installer function
function install_brew_cask_deps() {
  for pkg in "${brew_cask_packages[@]}"; do
    brew_cask_install $pkg
  done
}

## Brew configuration function
function config_brew() {
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ${HOME}/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
}

## Oh My ZSH installer function
function install_ohmyzsh() {
  if [[ ! -x /bin/zsh ]]; then
    rc=$(bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" &> /dev/null ; echo $?)
    if [[ ${rc} -ne 0 ]]; then
      Log "FATAL: OhMyZSH installation failed, abort" && exit 2
    fi
  fi
}

## Installation summary function
function summary() {
  cat <<__SUMMARY__
  Your laptop has been DevOps-tized. You have all the required tools
  to perform your day to day DevOps/SRE activities installed and configured.

  The script installed:
  $(for pkg in ${brew_packages[@]} ${brew_cask_packages[@]}; do echo "- ${pkg}" ; done )

  To start the Docker daemon and/or Kubernetes go to your application folder and run Docker.
  For Further informations, refer to:
    -> https://docs.docker.com/desktop/
    -> https://github.com/Homebrew/brew
    -> https://docs.github.com/en/get-started/getting-started-with-git/setting-your-username-in-git
    -> https://pre-commit.com/


__SUMMARY__
}

#
# MAIN
#
install_brew                # Install the brew package manager.
config_brew                 # Configure brew.
install_brew_deps           # Install the tools dependencies.
install_brew_cask_deps      # Install the tools dependencies.
install_ohmyzsh             # Install Oh My ZSH.
config_vim                  # Configure Vim.
config_zsh                  # Configure the theme for Oh My ZSH.
summary                     # Show the installation summary.
