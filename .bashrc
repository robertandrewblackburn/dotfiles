# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

###############################################################################
#                           Table of Contents
#------------------------------------------------------------------------------
#  0. Default configuration
#  |  These settings came with my installation of Pop!_OS (and I assume are the
#  |  Ubuntu defaults)
#  |
#  1. Command hooks
#  |  Custom 'hooks' to register commands to run before/after (pre/post)
#  |  commands. For example, to automatically run `ls` after `cd`
#  |
#  2. Path
#  |  Adding installed scripts/binaries to the $PATH variable
#  |
#  3. Aliases
#  |  3.1 Upgraded tools
#  |   |  These aliases replace 'standard' utils with preferred 'modern' 
#  |   |  equivalents (usually trying to be backwards compatible).
#  |   |  eg. `grep` --> `ripgrep`
#  |  3.2 Utility
#  |   |  Shortcuts and useful commands wrapped up for ease of use.
#  |   |  eg. `bashrc` to open this file for editing in VIM
#  | 
#
###############################################################################

# 0. Default configuration ####################################################

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=10000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# 0.1 Prompt ##################################################################

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(git_branch) \$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

###############################################################################
# 1. Command hooks

## cd

# commands in this array will be executed after cd completes
postcd_cmds=()
# Append to the list of commands to run after cd'ing
do_post_cd() {
  postcd_cmds+=($@)
}
# Function called after cd'ing
postcd() {
  for cmd in "${postcd_cmds[@]}";do
   eval "$cmd" 
  done
}

# cd hooks
cd_with_hooks() {
  # precd "$@"
  cd "$@";
  postcd
}

alias cd='cd_with_hooks'
# makes sure any custom CD stuff we set up applies to the first directory of the shell session
cd $PWD

###############################################################################
# 2. Path

# Rust
. "$HOME/.cargo/env"

# Deno
export DENO_INSTALL="/home/rab/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# add `~/bin`
export PATH="~/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# automatically call `nvm use` when CD'ing
cdnvm() {
    nvm_path=$(nvm_find_up .nvmrc | tr -d '\n')

    # If there are no .nvmrc file, use the default nvm version
    if [[ ! $nvm_path = *[^[:space:]]* ]]; then

        declare default_version;
        default_version=$(nvm version default);

        # If there is no default version, set it to `node`
        # This will use the latest version on your machine
        if [[ $default_version == "N/A" ]]; then
            nvm alias default node;
            default_version=$(nvm version default);
        fi

        # If the current version is not the default version, set it to use the default version
        if [[ $(nvm current) != "$default_version" ]]; then
            nvm use default;
        fi

        elif [[ -s $nvm_path/.nvmrc && -r $nvm_path/.nvmrc ]]; then
        declare nvm_version
        nvm_version=$(<"$nvm_path"/.nvmrc)

        declare locally_resolved_nvm_version
        # `nvm ls` will check all locally-available versions
        # If there are multiple matching versions, take the latest one
        # Remove the `->` and `*` characters and spaces
        # `locally_resolved_nvm_version` will be `N/A` if no local versions are found
        locally_resolved_nvm_version=$(nvm ls --no-colors "$nvm_version" | tail -1 | tr -d '\->*' | tr -d '[:space:]')

        # If it is not already installed, install it
        # `nvm install` will implicitly use the newly-installed version
        if [[ "$locally_resolved_nvm_version" == "N/A" ]]; then
            nvm install "$nvm_version";
        elif [[ $(nvm current) != "$locally_resolved_nvm_version" ]]; then
            nvm use "$nvm_version";
        fi
    fi
}
do_post_cd cdnvm

###############################################################################
# 3. Aliases

# modern rust equivalents
alias ls='exa --group-directories-first'
alias ll='ls -lF'
alias la='ls -aF'
alias l='ls -F'

alias grep='rg'
alias cat='batcat'

alias update='sudo apt update && sudo apt upgrade'

# Easy editing of .bashrc and .vimrc
alias bashrc='vim ~/.bashrc'
alias reload='source ~/.bashrc'
alias vimrc='vim ~/.vimrc'

# quick password generator
alias randompw="< /dev/random tr -dc 'a-zA-Z0-9-_\!@#\$%^&*()_+{}|:<>?=' | fold -w 12 | head -n 1"

# Add the current git branch to the prompt (when in a git repository)
function git_branch() {
    if [ -d .git ] ; then
        printf "%s" "($(git branch 2> /dev/null | awk '/\*/{print $2}'))";
    fi
}

# I wonder if this is a bad idea
alias python='python3'

# Use Podman instead of Docker
alias docker='podman'

alias dotfiles="cd ~/0_COMPUTE/Computer/dotfiles/ && git status"

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

# if tmux is executable, X is running, and not inside a tmux session, start a new one
if [ -x "$(command -v tmux)" ] && [ -n "${DISPLAY}" ]; then
  [ -z "${TMUX}" ] && { tmux; } >/dev/null 2>&1
fi

# Make Caps Lock act like Esc (unless holding shift key)
setxkbmap -option caps:escape_shifted_capslock
