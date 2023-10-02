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

message() {
    # Function to format messages in the CLI session
    #
    echo "### $1"
    echo "#"
}

update_packages() {
    # Function to update packages on the VM
    #
    message "Update $(lsb_release -ds) packages"
    sudo apt update
}

install_package() {
    # Function to install desired package on the VM
    #
    message "Install package: $1"
    sudo apt install -y "$1"
}

intsall_ohmyzsh() {
    # Function to install & configure oh-my-zsh
    #   https://ohmyz.sh/
    #   https://github.com/ohmyzsh/ohmyzsh
    #
    message "Install oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # Install plugins
    message "Install oh-my-zsh plugin: zsh-syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

    # Setup .zshrc config file to add desired plugins
    echo "Set plugins: ${PLUGINS}"
    sed -i "s/^plugins=(.*/plugins=(${PLUGINS})/g" .zshrc

    # Change default shell session for the user to use zsh prompt
    echo "Set shell in /etc/passwd"
    sudo sed -i "s/:\/home\/${USER_NAME}:.*/:\/home\/${USER_NAME}:\/usr\/bin\/zsh/g" /etc/passwd
    echo "Set shell in /etc/aadpasswd"
    sudo sed -i "s/:\/home\/${USER_NAME}:.*/:\/home\/${USER_NAME}:\/usr\/bin\/zsh/g" /etc/aadpasswd
}

install_custom_theme() {
    # Custom theme based on robbyrussell to show user@host
    # Host variable is provided by user during script run
    #
    message "Add custom theme"
    cat > ${HOME}/.oh-my-zsh/themes/robbyrussell.custom.zsh-theme <<EOF
PROMPT="\$USER@$1 %(?:%{\$fg_bold[green]%}➜ :%{\$fg_bold[red]%}➜ )"
PROMPT+=' %{\$fg[cyan]%}%c%{\$reset_color%} \$(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{\$fg_bold[blue]%}git:(%{\$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{\$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{\$fg[blue]%}) %{\$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{\$fg[blue]%})"
EOF
    echo "${HOME}/.oh-my-zsh/themes/robbyrussell.custom.zsh-theme"

    # Setup .zshrc config file to add custom theme
    #
    message "Setup .zshrc"
    echo "Set ZSH_THEME to robbyrussell.custom"
    sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"robbyrussell.custom\"/g" .zshrc
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

    # Install custom theme if HOST_NAME is provided as script argument
    if [ "$CUSTOM_THEME" = true ]; then
        install_custom_theme $HOST_NAME
    fi

}

main "$@"