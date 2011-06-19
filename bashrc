########################################################
# Path
########################################################

export PATH=~/bin:$PATH
export PYTHONPATH=~/lib:$PYTHONPATH

########################################################
# Terminal Prompt
########################################################

parse_git_branch() {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(git::\1) /'
}

parse_svn_url() {
  svn info 2>/dev/null | grep -e '^URL*' | sed -e 's#^URL: *\(.*\)#\1#g '
}
parse_svn_repository_root() {
  svn info 2>/dev/null | grep -e '^Repository Root:*' | sed -e 's#^Repository Root: *\(.*\)#\1\/#g '
}
parse_svn_branch() {
  parse_svn_url | sed -e 's#^'"$(parse_svn_repository_root)"'##g' | awk -F / '{print "(svn::"$1 "/" $2 ") "}'
}

store_exit_code() {
    EXIT_CODE=$?
}

exit_code() {
    [ "$EXIT_CODE" = "0" ] && return
    echo -n "$EXIT_CODE "
}

PROMPT_COMMAND=store_exit_code

export PS1="\[\033[1;34m\][\$(date +%H:%M)] \[\033[1;36m\]\u@\h \w \[\033[1;32m\]\$(parse_git_branch)\$(parse_svn_branch)\[\033[1;31m\]\$(exit_code)\[\033[1;36m\]$\[\033[0m\] "

########################################################
# Autocomplete
########################################################

_complete_git() {
  if [ -d .git ]; then
    branches=`git branch -a | cut -c 3-`
    tags=`git tag`
    cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "${branches} ${tags}" -- ${cur}) )
  fi
}
#complete -F _complete_git "git checkout"

# bash-completion mac ports package
if [ -f /opt/local/etc/bash_completion ]; then
  . /opt/local/etc/bash_completion
fi

if [ -f ~/bin/autocomplete_ssh_config.py ]; then
  complete -W "$(~/bin/autocomplete_ssh_config.py)" ssh
fi 

########################################################
# Aliases
########################################################

alias ls="ls -G"
alias ll="ls -ltr"

alias gs="git status"
alias gd="git diff"

alias logtail="tail -F '`ls -t | head -1`'"

e() {
    echo "/Applications/Aquamacs.app/Contents/MacOS/bin/emacsclient $1 &"
    /Applications/Aquamacs.app/Contents/MacOS/bin/emacsclient $1 &
}

alias nt="nosetests --nocapture --nologcapture --tests"

# alias pylons-start="source /Users/pariser/pylons/bin/activate"
# alias pylons-stop="deactivate"

