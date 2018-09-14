#!/bin/bash
# Install list of programs to setup new machine.
# For Linux, it first installs zsh/oh-my-zsh, then linuxbrew and then installs
# all other programs using brew.
# For Mac, it first installs brew and then all other programs using it
# (including zsh).
#
# Based on:
# * https://github.com/Cyclenerd/postinstall
# * https://opensource.com/business/15/3/automating-linux-install
#
#
# IMPORTANT
# * curl and git required
# * dot_files repo (https://github.com/mparada/dot_files) cloned to 
#   $HOME/Projects/_Tools/personal/dot_files
#

################################################################################
# Functions                                                                    #
################################################################################

################################################################################
# Helper functions                                                             #
################################################################################

# outputs and logs a message before exiting the script.
function exit_with_message() {
	echo
	echo "$1"
	echo -e "\n$1" >>"$INSTALL_LOG"
	if [[ $INSTALL_LOG && "$2" -eq 1 ]]; then
		echo "For additional information, check the install log: $INSTALL_LOG"
	fi
	echo
	exit 1
}

# shorthand for exit_with_message in case of failure
function exit_with_failure() {
	exit_with_message "FAILURE: $1" 1
}

# command_exists() tells if a given command exists.
function command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# set INSTALL_LOG as the path to a file in /tmp
function set_install_log() {
	if [[ ! $INSTALL_LOG ]]; then	
		export INSTALL_LOG="/tmp/install_$DATETIME.log"
	fi
}

################################################################################
# Main functions                                                               #
################################################################################

# obtains the operating system
# one of: Debian, Ubuntu, RedHat, CentOS
function detect_operating_system() {
	echo "Detecting operating system"
	echo -e "\nuname" >>"$INSTALL_LOG"
	OPERATING_SYSTEM_TYPE=$(uname)
	export OPERATING_SYSTEM_TYPE
	if [ -f /etc/debian_version ]; then
		echo -e "\ntest -f /etc/debian_version" >>"$INSTALL_LOG"
		echo "  -> Debian / Ubuntu"
        OPERATING_SYSTEM="DEBIAN"
    elif [ -f /etc/redhat-release ] || [ -f /etc/system-release-cpe ]; then
		echo -e "\ntest -f /etc/redhat-release || test -f /etc/system-release-cpe" >>"$INSTALL_LOG"
		echo "  -> Red Hat / Fedora / CentOS"
        OPERATING_SYSTEM="REDHAT"
    elif [ -f /System/Library/CoreServices/SystemVersion.plist ]; then
		echo -e "\ntest -f /System/Library/CoreServices/SystemVersion.plist" >>"$INSTALL_LOG"
		echo "  -> macOS"
        OPERATING_SYSTEM="MACOS"
    else
        {
			echo -e "\ntest -f /etc/debian_version"
			echo -e "\ntest -f /etc/redhat-release || test -f /etc/system-release-cpe"
        } >>"$INSTALL_LOG"
        exit_with_failure "Unsupported operating system"
    fi

    export OPERATING_SYSTEM
}

# obtains the operating system package management software
function detect_installer() {
	echo "Checking installation tools"
	case $OPERATING_SYSTEM in
        DEBIAN)
			if command_exists apt-get; then
				echo -e "\napt-get found" >>"$INSTALL_LOG"
				export MY_INSTALLER="apt-get"
				export MY_INSTALL="-y install"
			else
				exit_with_failure "Command 'apt-get' not found"
			fi
            ;;
        REDHAT)
			# https://fedoraproject.org/wiki/Dnf
			if command_exists dnf; then
				echo -e "\ndnf found" >>"$INSTALL_LOG"
				export MY_INSTALLER="dnf"
				export MY_INSTALL="-y install"
			# https://fedoraproject.org/wiki/Yum
			# As of Fedora 22, yum has been replaced with dnf.
			elif command_exists yum; then
				echo -e "\nyum found" >>"$INSTALL_LOG"
				export MY_INSTALLER="yum"
				export MY_INSTALL="-y install"
			else
				exit_with_failure "Either 'dnf' or 'yum' are needed"
			fi
			# RPM
			if command_exists rpm; then
				echo -e "\nrpm found" >>"$INSTALL_LOG"
			else
				exit_with_failure "Command 'rpm' not found"
			fi
            ;;
        MACOS)
			# homebrew
			if command_exists brew; then
				echo -e "\nbrew found" >>"$INSTALL_LOG"
				export MY_INSTALLER="brew"
				export MY_INSTALL="install"
			else
				exit_with_failure "'brew' is needed. More details can be found at https://brew.sh"
			fi
			# XCode and accept the end user license agreement
			if command_exists xcodebuild; then
				xcodebuild -license accept >>"$INSTALL_LOG" 2>&1
			else
				exit_with_failure "XCode not found. Install the latest XCode from the AppStore."
			fi
            ;;
    esac
    echo "  -> $MY_INSTALLER"
}

# re-synchronize the package index and install the newest versions of all packages currently installed
function resync_installer() {
	echo "Re-sync. the package index and install the newest versions (please wait, sometimes takes a little longer...)"
	case $MY_INSTALLER in
		apt-get)
			sudo $MY_INSTALLER update >>"$INSTALL_LOG" 2>&1
			if [ "$?" -ne 0 ]; then
				exit_with_failure "Failed to do $MY_INSTALLER update"
			fi
			sudo $MY_INSTALLER upgrade >>"$INSTALL_LOG" 2>&1
			if [ "$?" -ne 0 ]; then
				exit_with_failure "Failed to do $MY_INSTALLER update"
			fi
			;;
        dnf|yum)
			$MY_INSTALLER -y update >>"$INSTALL_LOG" 2>&1
			if [ "$?" -ne 0 ]; then
				exit_with_failure "Failed to do $MY_INSTALLER update"
			fi
            ;;
        brew)
			$MY_INSTALLER update >>"$INSTALL_LOG" 2>&1
			if [ "$?" -ne 0 ]; then
				exit_with_failure "Failed to do $MY_INSTALLER update"
			fi
			$MY_INSTALLER upgrade >>"$INSTALL_LOG" 2>&1
			if [ "$?" -ne 0 ]; then
				exit_with_failure "Failed to do $MY_INSTALLER upgrade"
			fi
            ;;
    esac
    echo "  Success"
}


# install ZSH and Oh-My-Zsh
function install_zsh_oh_my_zsh(){
	echo "Installing ZSH"
    if command_exists zsh; then
        echo "  zsh already installed"
    else
        if [$MY_INSTALLER = brew]; then
            $MY_INSTALLER $MY_INSTALL zsh zsh-completions
        else
            sudo $MY_INSTALLER $MY_INSTALL zsh
        fi
		if [ "$?" -ne 0 ]; then
		    exit_with_failure "Failed to install ZSH"
		fi
    fi

    echo "Make ZSH the default shell"
    grep -q zsh <<< $SHELL
    if [ "$?" -eq 0 ]; then
        echo "   zsh already default shell"
    else
        chsh -s $(which zsh)
		if [ "$?" -ne 0 ]; then
		    exit_with_failure "Failed to do change default shell"
		fi
    fi

	echo "Installing Oh-My-Zsh"
    if [ -d ~/.oh-my-zsh ]; then
        echo "  oh-my-zsh already installed"
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    fi
}

# install (linux)brew
function install_brew(){
    echo "Installing brew"
    if command_exists brew; then
        echo "  brew already installed"
    else
        if [ "$OPERATING_SYSTEM_TYPE" == "Linux" ]; then
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
		    if [ "$?" -ne 0 ]; then
		        exit_with_failure "Failed to install linuxbrew"
		    fi
        elif [ "$OPERATING_SYSTEM_TYPE" == "Darwin" ]; then
            /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
		    if [ "$?" -ne 0 ]; then
		        exit_with_failure "Failed to install brew"
		    fi
        fi
    echo "  Success"
    fi
}

# install and update anaconda
function install_anaconda(){
    echo "Installing anaconda"
    if command_exists conda; then
        echo "  conda already installed"
    else
        case $OPERATING_SYSTEM_TYPE in
            Linux)
                wget https://repo.continuum.io/archive/Anaconda3-5.2.0-Linux-x86_64.sh -O $HOME/anaconda.sh
                bash ~/anaconda.sh -b -p $HOME/anaconda
            ;;
            Darwin)
                sh -c "$(curl -fsSL https://repo.anaconda.com/archive/Anaconda3-5.2.0-MacOSX-x86_64.sh)"
            ;;
        esac
		if [ "$?" -ne 0 ]; then
		    exit_with_failure "Failed to install anaconda"
		fi
    fi
    echo "  updating conda"
    conda update conda
	if [ "$?" -ne 0 ]; then
	    exit_with_failure "Failed to update anaconda"
	fi
    conda config --add channels conda-forge
    echo "  Success"
}

# install conda packages
function install_conda_packages(){
    echo "Installing conda packages"
    conda install $CONDA_PACKAGES
    if [ "$?" -ne 0 ]; then
        exit_with_failure "Failed to install conda packages"
    fi
    echo "  Success"
}

# install brew packages
function install_brew_packages(){
    echo "Installing brew packages"
    brew install $BREW_PACKAGES
    if [ "$?" -ne 0 ]; then
        exit_with_failure "Failed to install brew packages"
    fi
    echo "  Success"
}

# install neovim python packages
function install_nvim_python_packages(){
    echo "Installing neovim python packages"
    pip2 install --user neovim
    pip install --user neovim # this should be python 3
    if [ "$?" -ne 0 ]; then
        exit_with_failure "Failed to install neovim python packages"
    fi
    echo "  Success"
}

# setup vimplug
function install_vimplug(){
    echo "Installing vimplug"
    curl -fLo $HOME/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    if [ "$?" -ne 0 ]; then
        exit_with_failure "Failed to install vimplug"
    fi
    echo "  Success"
}

# install vim packages
function install_vim_packages(){
    echo "Installing vim packages with vimplug"
    nvim +'PlugInstall --sync' +qa
    if [ "$?" -ne 0 ]; then
        exit_with_failure "Failed to install packages with vimplug"
    fi
    echo "  Success"
}


################################################################################
# Config functions                                                             #
################################################################################

# create symlink $2 at location $1 with name $3
function create_symlink(){
    echo "  Creating symlink $1/$3 -> $2"
    if [ -L "$1/$3" ]; then
        echo "    Symlink for $3 already present"
    else
        if [ ! -d $1 ]; then
            mkdir -p $1
        fi
		ln -sf $HOME/Projects/_Tools/personal/dot_files/$2 $1/$3
        if [ "$?" -ne 0 ]; then
            exit_with_failure "Failed to create symlink $3"
        fi
    fi
}

# create symlinks from file $1
function create_symlinks(){
    echo "Creating symlinks to config files"
    while read i; do
        eval create_symlink $i
    done <$1
}

################################################################################
# Lists                                                                        #
################################################################################

BREW_PACKAGES="fzf neovim pgcli python@2"
CONDA_PACKAGES="cookiecutter psycopg2"
SYMLINK_LIST="$HOME/Projects/_Tools/personal/dot_files/symlink.list"
SYMLINK_LINUX_LIST="$HOME/Projects/_Tools/personal/dot_files/symlink_linux.list"
SYMLINK_MACOS_LIST="$HOME/Projects/_Tools/personal/dot_files/symlink_macos.list"

################################################################################
# Main                                                                         #
################################################################################

# Initial variables
DATETIME=$(date "+%Y-%m-%d-%H-%M-%S")

# Additions to path to be able to use newly installed software
export PATH="$HOME/anaconda/bin:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"

set_install_log
detect_operating_system
detect_installer
resync_installer

# in Linux: first zsh, then brew. In Mac: first brew, then zsh
case $OPERATING_SYSTEM_TYPE in
    Linux)
        install_zsh_oh_my_zsh
        install_brew
        ;;
    Darwin)
        install_brew
        install_zsh_oh_my_zsh
        ;;
esac

install_anaconda
install_conda_packages
install_brew_packages
install_nvim_python_packages
install_vimplug
create_symlinks $SYMLINK_LIST

# OS specifc symlinks 
case $OPERATING_SYSTEM_TYPE in
    Linux)
        create_symlinks $SYMLINK_LINUX_LIST
        ;;
    Darwin)
        create_symlinks $SYMLINK_MACOS_LIST
        ;;
esac

install_vim_packages

echo
echo "Installation finished"
