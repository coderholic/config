# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# sets the title of the xterm (or the current tab)
export PROMPT_COMMAND='echo -ne "\033]0;${PWD}\007"'

#enable bash completion
[ -f /etc/profile.d/bash-completion ] && source /etc/profile.d/bash-completion

# default bash_history is 500
export HISTSIZE=1000
export HISTFILESIZE=1000
export HISTCONTROL=ignoredups

export BROWSER=firefox-bin

# make pilot-xfer go faster than 9600
export PILOTRATE=57600
# make it append, rather than overwrite the history
shopt -s histappend
# fix typos
shopt -s cdspell

umask 022

export LS_OPTIONS='--color=yes'
eval `dircolors`
alias ls='ls $LS_OPTIONS --color'
alias ll='ls $LS_OPTION -lh --color'
alias l='ls $LS_OPTIONS -Ff --color'
alias la='ls $LS_OPTIONS -af --color'
alias ld='ls -d $LS_OPTIONS -af --color'  # directories only!
alias pgrep='pgrep -lf'
#
# Some more alias to avoid making mistakes:
alias copy='cp'

#  -h makes the numbers human
alias df='df -h'
alias du='du -h -c'
alias ps='ps'
alias ping='ping -c 5'
alias mkdir='mkdir -p'
alias grep='grep --colour'

alias Aemerge='ACCEPT_KEYWORDS="~amd64" emerge -s'
alias ftp='lftp'
export INPUTRC=~/.inputrc

export PROMPT_COMMAND='echo -n -e "\033k\033\0134"'

# functions so you don't have to type '&' for graphical binaries
function display
{
  command display "$@" &
}
function gedit
{
  command gedit "$@" &
}
function scite
{
  command scite "$@" &
}
function gimp
{
  command gimp "$@" &
}

# A fix for Synergy. Map « -> < and » -> > and omega -> @
echo "keycode 52 = z Z less less less less" | xmodmap -
echo "keycode 53 = x X greater greater greater greater" | xmodmap -
echo "keycode 24 = q Q at at at at" | xmodmap -

# Set screen title to the currently running command. Include arguments if the command is "ssh" so we know what 
# host each tab is connected to. Adapted from http://reluctanthacker.rollett.org/node/29/, which in turn is
# based on http://www.davidpashley.com/articles/xterm-titles-with-bash.html
set -o functrace
trap 'test ${BASH_COMMAND:0:3} == "ssh" && echo -ne "\ek${BASH_COMMAND}\e\\" || echo -ne "\ek${BASH_COMMAND% *}\e\\"' DEBUG
export PS1='\[\033[1;20m\]\h|\[\033[1;35m\]\u \[\033[1;34m\]/\W:\[\033[0m\] '

fortune
