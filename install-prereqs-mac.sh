#!/bin/bash

#install xcode if missing
xcode-select --install

#install homebrew if missing
echo "Checking homebrew..."
$(which -s brew)
if [[ $? != 0 ]] ; then
    echo "installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "Homebrew installed"
fi

#install necessary homebrew packages
brew tap ardupilot/ardupilot
brew update
brew install gcc-arm-none-eabi
brew install gawk
brew install ccache

CCACHE_PATH=$(which ccache)
echo "Registering STM32 Toolchain for ccache"
sudo ln -s -f $CCACHE_PATH /usr/local/opt/ccache/libexec
echo "Done!"

echo "Checking pip..."
$(which -s pip)
if [[ $? != 0 ]] ; then
    echo "installing pip..."
    sudo easy_install pip
else
    echo "pip installed"
fi

pip2 install --user pyserial pymavlink future lxml empy mavproxy pexpect pygame intelhex

SCRIPT_DIR=$(dirname $(realpath ${BASH_SOURCE[0]}))
ARDUPILOT_ROOT=$(realpath "$SCRIPT_DIR/../../")
ARDUPILOT_TOOLS="Tools/autotest"

exportline="export PATH=$ARDUPILOT_ROOT/$ARDUPILOT_TOOLS:\$PATH";
grep -Fxq "$exportline" ~/.profile 2>/dev/null || {
    read -p "Add $ARDUPILOT_ROOT/$ARDUPILOT_TOOLS to your PATH [N/y]?" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]] ; then
        echo $exportline >> ~/.profile
        eval $exportline
    else
        echo "Skipping adding $ARDUPILOT_ROOT/$ARDUPILOT_TOOLS to PATH."
    fi
}

git submodule update --init --recursive

echo "finished"
