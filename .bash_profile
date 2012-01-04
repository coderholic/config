# If not running interactively, don't do anything
[ -z "$PS1" ] && return

PYTHONSTARTUP=~/.pythonrc.py
export PYTHONSTARTUP

# sets the title of the xterm (or the current tab)
export PROMPT_COMMAND='echo -ne "\033]0;${PWD}\007"'

#enable bash completion
[ -f /etc/bash-completion ] && source /etc/bash-completion


function lastcommandfailed() {
  code=$?
  if [ $code != 0 ]; then
    echo -n $'\033[37;1m[exited \033[31;1m'
    echo -n $code
    echo -n $'\033[37;1m] '
  fi
}

function activevirtualenv() {
  if [ -n "$VIRTUAL_ENV" ]; then
      echo -n "("
      echo -n $(basename $VIRTUAL_ENV)
      echo -n ") "
  fi
}

# default bash_history is 500
export HISTSIZE=1000
export HISTFILESIZE=1000
export HISTCONTROL=ignoredups
shopt -s histappend

umask 022

export LS_OPTIONS='--color=yes'
alias ll='ls $LS_OPTION -lh --color'
alias l='ls $LS_OPTIONS -Ff --color'
alias ld='ls -d $LS_OPTIONS -af --color'  # directories only!
alias pgrep='pgrep -lf'

#  -h makes the numbers human
alias df='df -h'
alias du='du -h -c'
alias ps='ps'
alias ping='ping -c 5'
alias mkdir='mkdir -p'
alias grep='grep --colour'

export INPUTRC=~/.inputrc
export PROMPT_COMMAND='echo -n -e "\033k\033\0134"'

# functions so you don't have to type '&' for graphical binaries
function display
{
  command display "$@" &
}

if [ `uname` == "Darwin" ]; then
    # Mac specific code
    alias ls='ls -G'
    alias vim='mvim -v -p'
    export ARCHFLAGS="-arch i386 -arch x86_64"
    export PATH="/usr/local/bin/:$PATH"
    export PATH="$PATH:/usr/local/mysql/bin/"
else
    # Non-mac specific code

    # Bind caps lock to control
    xmodmap -e 'keycode 66 = Control_L'
    xmodmap -e 'clear Lock'
    xmodmap -e 'add Control = Control_L' 
fi

function pyopen() {
  vim `pyfind $@`
}

function pyfind() {
  x=`python -c "import $1; print $1.__file__" | sed 's/\.pyc$/\.py/'`;
  if [ $? -ne 0 ]; then
    exit $?
  fi
  grep -q "__init__.py$" <<< $x && echo `dirname $x` || echo $x
}

alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative" 

# Set screen title to the currently running command. Include arguments if the command is "ssh" so we know what 
# host each tab is connected to. Adapted from http://reluctanthacker.rollett.org/node/29/, which in turn is
# based on http://www.davidpashley.com/articles/xterm-titles-with-bash.html
#set -o functrace
#trap 'test "ssh" == "${BASH_COMMAND:0:3}" && echo -ne "\ek${BASH_COMMAND}\e\\" || echo -ne "\ek${BASH_COMMAND%% *}\e\\"' DEBUG

# taken from http://plasti.cx/2009/10/23/vebose-git-dirty-prompt
# origin of work http://henrik.nyh.se/2008/12/git-dirty-prompt
function parse_git_dirty {
status=$(git status 2> /dev/null)
  dirty=`    echo -n "${status}" 2> /dev/null | grep -q "Changed but not updated" 2> /dev/null; echo "$?"`
  untracked=`echo -n "${status}" 2> /dev/null | grep -q "Untracked files" 2> /dev/null; echo "$?"`
  ahead=`    echo -n "${status}" 2> /dev/null | grep -q "Your branch is ahead of" 2> /dev/null; echo "$?"`
  newfile=`  echo -n "${status}" 2> /dev/null | grep -q "new file:" 2> /dev/null; echo "$?"`
  renamed=`  echo -n "${status}" 2> /dev/null | grep -q "renamed:" 2> /dev/null; echo "$?"`
  bits=''
  if [ "${dirty}" == "0" ]; then
    bits="${bits}*"
  fi
  if [ "${untracked}" == "0" ]; then
    bits="${bits}?"
  fi
  #if [ "${newfile}" == "0" ]; then
  #  bits="${bits}*"
  #fi
  if [ "${ahead}" == "0" ]; then
    bits="${bits}+"
  fi
  if [ "${renamed}" == "0" ]; then
    bits="${bits}>"
  fi
  echo "${bits}"
}

function parse_git_branch {
    ref=$(git branch 2>/dev/null|grep \*|sed 's/* //') || return
    if [ "$ref" != "" ]
    then
        echo "("${ref}$(parse_git_dirty)") "
    fi
}

DEFAULT_COLOR="[33;0m"
GRAY_COLOR="[37;1m"
PINK_COLOR="[35;1m"
GREEN_COLOR="[32;1m"
CYAN_COLOR="[36;1m"
RED_COLOR="[31;1m"
ORANGE_COLOR="[33;1m"
RED="\[\033[0;31m\]"
YELLOW="\[\033[0;33m\]"
GREEN="\[\033[0;32m\]"
LIGHT_PURPLE="\[\033[1;34m\]"
WHITE="\[\033[1;20m\]"
CYAN="\[\033[1;35m\]"
export PS1="$WHITE\h|$CYAN\u $YELLOW\$(parse_git_branch)$LIGHT_PURPLE/\W:\[\033[0m\] "

BASEPROMPT="$WHITE\$(lastcommandfailed)[\A] \h|\[\e${PINK_COLOR}\]\u\[\e${ORANGE_COLOR}\] \$(activevirtualenv)\[\e${RED_COLOR}\]\$(parse_git_branch)\[\e${GREEN_COLOR}\]\w\[\e${DEFAULT_COLOR}\]"
PROMPT="${BASEPROMPT}\n\[\e${CYAN_COLOR}\]$ \[\e${DEFAULT_COLOR}\]"
export PS1=$PROMPT

# python
export PYTHONDONTWRITEBYTECODE=1
export PYTHONSTARTUP="$HOME/.pythonrc.py"
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--no-site-packages --distribute'

# virtualenvwrapper and pip
if [ `id -u` != '0' ]; then
  export VIRTUALENV_USE_DISTRIBUTE=1
  export WORKON_HOME=$HOME/.virtualenvs
  export PIP_VIRTUALENV_BASE=$WORKON_HOME
  export PIP_REQUIRE_VIRTUALENV=true
  export PIP_RESPECT_VIRTUALENV=true
  export VIRTUAL_ENV_DISABLE_PROMPT=1
  if [ -e "/usr/local/bin/virtualenvwrapper.sh" ]; then
    source /usr/local/bin/virtualenvwrapper.sh
  fi
fi

fortune
