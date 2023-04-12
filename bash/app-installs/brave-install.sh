#!/bin/bash

#VARIABLES
"${DEB_REPO = "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"}"
"${RPM_REPO = "https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo"}"

#operating system checker
detect_os() {
  if [ -f "/etc/os-release" ]; then
    . /etc/os-release
    OS=$NAME
    VERSION=$VERSION_ID
  elif [ -f "/etc/redhat-release" ]; then
    #using redhat-release instead of /etc/os-release for fun
    OS=$(cat /etc/redhat-release | awk '{print $1}')
    VERSION=$(cat /etc/redhat-release | awk '{print $(NF-1)}' | tr -d '()')
  else
    echo "Unsupported operating system"
    exit 1
  fi
}

#debian/ubuntu/mint install
brave-debian() {
  sudo apt install curl
  sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "$DEB_REPO" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  sudo apt update
  sudo apt install brave-browser
}

#RHEL/centOS/Fedora install
brave-rhel(){
  sudo dnf install dnf-plugins-cor
  sudo dnf config-manager --add-repo "$RPM_REPO"
  sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
  sudo dnf install brave-browser-beta
}

#OpenSUSE install
brave-suse(){
sudo zypper install curl
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo zypper addrepo "$RPM_REPO"
sudo zypper install brave-browser
}

#OS check
detect_os

# Check if the OS is supported and run the commands the proper commands for your operating system
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
  *)
    echo "Unsupported operating system: $OS"
    exit 1
    ;;
esac