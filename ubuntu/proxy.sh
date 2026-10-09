#!/usr/bin/sh
#
# Script to prepare proxy config on Ubuntu Virtual Machine to install oh-my-zsh using install.sh script
#
# This script can be run using curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/Pigiel/scripts/main/ubuntu/proxy.sh)"
#
# Before running the script export socks5 proxy environment variables:
#   export HTTP_PROXY="socks5h://127.0.0.1:1080"
#   export HTTPS_PROXY="socks5h://127.0.0.1:1080"
#
# Kubelogin version to install
#
KUBELOGIN_VERSION="v0.2.20"

# Socks5 proxy configuration file path
SOCKS_PROXY_CONF="/etc/apt/apt.conf.d/99socks-proxy"

# Color setup
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
DARK_GRAY='\033[1;30m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
LIGHT_YELLOW='\033[1;33m'
LIGHT_CYAN='\033[1;36m'

header() {
    # Function to format headers in the CLI session
    #
    printf "${DARK_GRAY}##############################################################\n"
    printf "# ${LIGHT_RED}$1${DARK_GRAY}\n"
    printf "##############################################################\n${RESET}"
}

section() {
    # Function to format sections in the CLI session
    #
    printf "${YELLOW}> $1${RESET}\n"
}

info() {
    # Function to format information messages in the CLI session
    #
    printf "${CYAN}$1${RESET}\n"
}

set_apt_proxy() {
  header "Setting APT proxy: $SOCKS_PROXY_CONF"
  echo 'Acquire::http::Proxy "socks5h://127.0.0.1:1080/";' | sudo tee -a "$SOCKS_PROXY_CONF"
  echo 'Acquire::https::Proxy "socks5h://127.0.0.1:1080/";' | sudo tee -a "$SOCKS_PROXY_CONF"
  cat "$SOCKS_PROXY_CONF"
}

remove_apt_proxy() {
  header "Remove APT proxy command"
  echo "When oh-my-zsh installation is done, you can remove the APT proxy using the following command:"
  info "sudo rm -f $SOCKS_PROXY_CONF"
}

clone_kubectx() {
  sudo http_proxy=socks5h://127.0.0.1:1080 https_proxy=socks5h://127.0.0.1:1080 git clone https://github.com/ahmetb/kubectx /opt/kubectx
}

install_kubelogin() {
  header "Installing kubelogin version $KUBELOGIN_VERSION"
  curl -LO https://github.com/Azure/kubelogin/releases/download/$KUBELOGIN_VERSION/kubelogin-linux-amd64.zip
  python3 -m zipfile -e kubelogin-linux-amd64.zip .
  sudo mv bin/linux_amd64/kubelogin /usr/local/bin/kubelogin
  rm -rf kubelogin-linux-amd64.zip bin/

  sudo chown root:root /usr/local/bin/kubelogin
  sudo chmod 755 /usr/local/bin/kubelogin
}

main() {
  set_apt_proxy
  clone_kubectx
  install_kubelogin
  remove_apt_proxy
}

main "$@"
