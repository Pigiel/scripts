#!/usr/bin/sh
#
# Script to configure oh-my-zsh on Ubuntu Virtual Machine
# 
# This script can be run using curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/Pigiel/scripts/main/ubuntu/install.sh)" "" ${HOST_NAME}
#
# Plugins to add into .zshrc config
#
PLUGINS="git docker docker-compose kubectl zsh-syntax-highlighting kube-ps1"

# Current logged user on the Virtual Machine
# If username contains domain name (e.g. when login via Azure AD) then domain will be removed
#   e.g user@domain.com -> user
USER_NAME="$(echo $USER | cut -d '@' -f 1)"

# Default script variable values
HOST_NAME=""
CUSTOM_THEME=false
KUBE_PS_1=false

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

update_packages() {
    # Function to update packages on the VM
    #
    header "Update $(lsb_release -ds) packages"
    sudo apt update
}

install_package() {
    # Function to install desired package on the VM
    #
    section "Install package: $1"
    sudo apt install -y "$1"
}

intsall_ohmyzsh() {
    # Function to install & configure oh-my-zsh
    #   https://ohmyz.sh/
    #   https://github.com/ohmyzsh/ohmyzsh
    #
    header "Install oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # Install plugins
    header "Install oh-my-zsh plugins"
    section "zsh-syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

    # Setup .zshrc config file
    # Activate plugins
    info "Set plugins: ${PLUGINS}"
    sed -i "s/^plugins=(.*/plugins=(${PLUGINS})/g" .zshrc
    # Set zsh command prompt to use kube-ps1 plugin
    grep -qxF "PROMPT='\$(kube_ps1) '\$PROMPT" .zshrc || sed -i "78 i PROMPT='\$(kube_ps1) '\$PROMPT" .zshrc 

    # Change default shell session for the user to use zsh prompt
    info "Set shell in /etc/passwd"
    sudo sed -i "s/:\/home\/${USER_NAME}:.*/:\/home\/${USER_NAME}:\/usr\/bin\/zsh/g" /etc/passwd
    info "Set shell in /etc/aadpasswd"
    sudo sed -i "s/:\/home\/${USER_NAME}:.*/:\/home\/${USER_NAME}:\/usr\/bin\/zsh/g" /etc/aadpasswd
}

install_custom_theme() {
    # Custom theme based on robbyrussell to show user@host
    # Host variable is provided by user during script run
    #
    section "Add custom theme"
    cat > ${HOME}/.oh-my-zsh/themes/robbyrussell.custom.zsh-theme <<EOF
PROMPT="\$USER@$1 %(?:%{\$fg_bold[green]%}➜ :%{\$fg_bold[red]%}➜ )"
PROMPT+=' %{\$fg[cyan]%}%c%{\$reset_color%} \$(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{\$fg_bold[blue]%}git:(%{\$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{\$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{\$fg[blue]%}) %{\$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{\$fg[blue]%})"
EOF
    info "${HOME}/.oh-my-zsh/themes/robbyrussell.custom.zsh-theme"

    # Setup .zshrc config file to add custom theme
    #
    section "Setup .zshrc"
    info "Set ZSH_THEME to robbyrussell.custom"
    sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"robbyrussell.custom\"/g" .zshrc
}

install_kubectx() {
    # kubectx + kubens: Power tools for kubectl
    #   https://github.com/ahmetb/kubectx
    #
    # kubectx is a tool to switch between contexts (clusters) on kubectl faster.
    # kubens is a tool to switch between Kubernetes namespaces (and configure them for kubectl) easily.
    #
    header "Install ahmetb/kubectx"
    sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
    sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
    sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

    section "Configure completion scrips for plain zsh"
    info "Create directory: ~/.oh-my-zsh/custom/completions"
    mkdir -p ~/.oh-my-zsh/custom/completions
    chmod -R 755 ~/.oh-my-zsh/custom/completions
    info "Add completion links"
    ln -s /opt/kubectx/completion/_kubectx.zsh ~/.oh-my-zsh/custom/completions/_kubectx.zsh
    ln -s /opt/kubectx/completion/_kubens.zsh ~/.oh-my-zsh/custom/completions/_kubens.zsh
    info "Setup .zshrc"
    grep -qxF "fpath=(\$ZSH/custom/completions \$fpath)" .zshrc || sed -i "79 i fpath=(\$ZSH/custom/completions \$fpath)" .zshrc
    grep -qxF "autoload -U compinit && compinit" .zshrc || sed -i "80 i autoload -U compinit && compinit" .zshrc
}

main() {

    if [ ! -t 0 ]; then
        HOST_NAME=$HOST
    else
        HOST_NAME=$1
    fi

    update_packages
    install_package zsh
    intsall_ohmyzsh
    install_kubectx

    # Install custom theme if HOST_NAME is provided as script argument
    if [ "$CUSTOM_THEME" = true ]; then
        install_custom_theme $HOST_NAME
    fi

}

main "$@"