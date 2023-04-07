#!/bin/bash

#VARIABLES
DEB_REPO="deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"
RHEL_REPO="https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo"

# trivial os detection
detect_os() {
  if [ -f "/etc/os-release" ]; then
    . /etc/os-release
    OS=$NAME
    VERSION=$VERSION_ID
  elif [ -f "/etc/redhat-release" ]; then
    # Using redhat-release instead of /etc/os-release for fun
    OS=$(cat /etc/redhat-release | awk '{print $1}')
    VERSION=$(cat /etc/redhat-release | awk '{print $(NF-1)}' | tr -d '()')

  elif [ -f "/etc/arch-release" ] && grep -q "Manjaro" /etc/os-release; then
    # This check is specific to Manjaro Linux
    OS="Manjaro Linux"
    VERSION=$(grep "VERSION_ID" /etc/os-release | cut -d '=' -f 2 | tr -d '"')

  elif [ -f "/etc/arch-release" ]; then
    # This check is for Arch Linux
    OS="Arch Linux"
    VERSION=$(uname -r)

  else
    echo "Unsupported operating system"
    exit 1
  fi
}

#debian/ubuntu/mint install
brave-debian() {
    echo "Running my commands..."
    sudo apt install curl
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "$DEB_REPO" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update
    sudo apt install brave-browser
}

#RHEL/centOS/Fedora install
brave-rhel(){
    sudo dnf install dnf-plugins-core
    sudo dnf config-manager --add-repo "$RHEL_REPO"
    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
    sudo dnf install brave-browser
}

#OpenSUSE install
brave-suse(){
    sudo zypper install curl
    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
    sudo zypper addrepo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
    sudo zypper install brave-browser
}

#arch btw
brave-arch(){
    yay -S brave-bin
}

#Manjaro install
brave-manjaro(){
    pacman -S brave-browser
}

detect_os

#Checks output of detect_os and runs the function for your operating system
case $OS in
  "Debian GNU/Linux" | "Ubuntu" | "Linux Mint")
    echo "You are running $OS $VERSION"
    brave-debian
    ;;
  "Fedora" | "CentOS Linux" | "Red Hat Enterprise Linux")
    echo "You are running $OS $VERSION"
    brave-rhel
    ;;
  "openSUSE Leap" | "openSUSE Tumbleweed")
    echo "You are running $OS $VERSION"
    brave-suse
    ;;
  "Arch Linux")
    echo "You are running $OS $VERSION"
    brave-arch
    ;;
  "Manjaro Linux")
    echo "You are running $OS $VERSION"
    brave-manjaro
    ;;
  *)
    echo "Unsupported operating system: $OS"
    exit 1
    ;;
esac