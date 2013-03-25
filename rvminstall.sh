#!/bin/bash
# taken from http://rails.vandenabeele.com/blog/2011/11/26/installing-ruby-and-rails-with-rvm-on-ubuntu-11-dot-10/

# verify root execution
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
  echo "this script requires root permissions"
  echo "try: sudo $0"
  exit 1
fi

# check that RVM is not already installed
if [ rvminstalled ]; then
  echo "RVM is already installed"
  echo "try: rvm use 1.9.3"
  exit 1
fi

# take a copy of your .bashrc since it will be
# modified by rvm install
echo "Backing up .bashrc to .bashrc.ORIGINAL"
cp $HOME/.bashrc $HOME/.bashrc.ORIGINAL

# install some requirements for rvm install
apt-get install curl libcurl3
apt-get install git-core liberror-perl

# Based on http://beginrescueend.com/rvm/install/ execute a single user install of rvm
bash < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer )

# re-execute profile to reload with RVM
. $HOME/.profile

if [ ! rvminstalled ]; then
  echo "RVM installation failed"
  exit 1
fi

rvm install 1.8.7
exitiffailed
rvm install 1.9.3
exitiffailed

USECMD=$(rvm use 1.9.3)
exitiffailed
REGEX="Using(.*)(1\.9\.3)"
if [[ ! $1 =~ $regex ]]; then
  echo "Failed trying -> $USECMD"
  exit 1
fi

# =====================================
# ============= Functions =============
# =====================================

# verify that rvm was installed
function rvminstalled {
  TEST=$(type rvm | head -1)
  CORRECT="rvm is a function"
  if [ "$TEST" == "$CORRECT" ]; then
    echo "rvm function not found."
    return false
  else
    return true
  fi
}

function exitiffailed {
  if [ $? != 0 ]; then
    if [ "$#" -eq 1 ]; then
      echo $1
    fi

    exit 1
  fi
  
}