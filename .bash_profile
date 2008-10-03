# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# ~/.bashrc: executed by bash(1) for non-login shells.

#export PS1="[\u \W]:"
export PS1="\[\033[1;20m\]\h|\[\033[1;35m\]\u \[\033[1;34m\]/\W:\[\033[0m\] "
# it's possible that this will make bash find my delete key (and everything else)((but i don't think it did))
export INPUTRC=/etc/inputrc
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

CDPATH=.:..:../..:~:/usr/src:/home/radagast
PATH=$PATH:/home/radagast/Lang/bash
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
alias g="grep"

alias ssh='ssh -X'

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
function gpdf
{
  command gpdf "$@" &
}
function scite
{
  command scite "$@" &
}
function gimp
{
  command gimp "$@" &
}
function konqueror
{
  command konqueror "$@" &
}
function locateetc
{
  command locate -i "$@" | grep etc
}
function locatedoc
{
  command locate -i "$@" | grep /doc
}
function locatebin
{
  command locate -i "$@" | grep bin/
}
function locategrep
{
  if [ "${#}" != 2 ] ; then
    echo "Usage: locategrep [string to locate] [string to grep]";
    return 1;
  else
    echo "locate -i '${1}' | grep -i '${2}'";
    command locate -i '${1}' | grep -i '${2}';
  fi;
}
function psgrep
{
  command ps -A -o pid,uname,%cpu,%mem,stat,time,args | grep "$@"
#command echo "use pgrep"
}
function mozilla
{
  command mozilla "$@" &
}
function porthole
{
  command sudo porthole &
}
function realplay
{
  command aoss realplay "$@" &
}
function kman
{
  command khelpcenter man:/"$@"
}
# finally, a calculator!!
calc () 
{ echo "$*" | bc -l; }


# A fix for Synergy. Map « -> < and » -> >
echo "keycode 52 = z Z less less less less" | xmodmap -
echo "keycode 53 = x X greater greater greater greater" | xmodmap -
echo "keycode 24 = q Q at at at at" | xmodmap -

fortune
