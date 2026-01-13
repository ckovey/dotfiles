# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

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
HISTSIZE=-1
HISTFILESIZE=-1

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

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
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

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

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

function git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}

if git --version &>/dev/null; then
  # PS1 Line to show current Git Branch in the Prompt
  PS1='\[\e[38;5;241;48;5;235m\]\A\[\e[m\][\u@\H \[\e[38;5;33m\]\W\[\e[m\]] \[\e[38;5;40m\]$(git_branch)\[\e[m\]\$ '
else
  # Original PS1 Line
  PS1='\[\e[38;5;241;48;5;235m\]\A\[\e[m\][\u@\H \[\e[38;5;33m\]\W\[\e[m\]] \$ '
fi

bind 'set completion-ignore-case on'

# for plebs
export VISUAL="nano"
export EDITOR="nano"

# better auditing
HISTTIMEFORMAT="%Y-%m-%d %T "            # format history timestamp
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it
export PROMPT_COMMAND='history -a'       # append to history immediately

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# automatically switch to node version when .nvmrc found
find-up () {
    path=$(pwd)
    while [[ "$path" != "" && ! -e "$path/$1" ]]; do
        path=${path%/*}
    done
    echo "$path"
}

cdnvm(){
    cd "$@";
    nvm_path=$(find-up .nvmrc | tr -d '\n')

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
alias cd='cdnvm'

# connect to windows pageant for ssh keys
if grep -q Microsoft /proc/version; then
  eval $(/mnt/c/Users/Chris/.ssh/weasel-pageant-1.4/weasel-pageant -r)
fi

# Composer
export PATH="$PATH:./vendor/bin"
export PATH="$PATH:$HOME/.config/composer/vendor/bin"

_artisan()
{
    local arg="${COMP_LINE#php }"

    case "$arg" in
        artisan*)
            COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
            COMMANDS=`php artisan --raw --no-ansi list | sed "s/[[:space:]].*//g"`
            COMPREPLY=(`compgen -W "$COMMANDS" -- "${COMP_WORDS[COMP_CWORD]}"`)
            ;;
        *)
            COMPREPLY=( $(compgen -o default -- "${COMP_WORDS[COMP_CWORD]}") )
            ;;
        esac

    return 0
}
complete -F _artisan php


# Created by `pipx` on 2026-01-02 17:52:39
export PATH="$PATH:/home/chris/.local/bin"

# ---- SSH Agent (WSL) ----
export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"

# Start an agent only if the socket is missing or stale
if ! ssh-add -l >/dev/null 2>&1; then
  # If a stale socket exists, remove it
  if [ -S "$SSH_AUTH_SOCK" ]; then
    rm -f "$SSH_AUTH_SOCK"
  fi

  # Start agent bound to the fixed socket
  eval "$(ssh-agent -a "$SSH_AUTH_SOCK")" >/dev/null

  # Load your key once per agent lifetime (adjust key path as needed)
  # If the key has a passphrase, you'll be prompted once (per agent lifetime).
  ssh-add "$HOME/.ssh/id_rsa" </dev/null
fi
# -------------------------
