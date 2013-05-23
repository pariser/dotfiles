## -*- mode: Shell-script; -*-

########################################################
# Path
########################################################

export PATH=~/bin:/usr/local/lib/node_modules:$PATH
export PYTHONPATH=~/lib:$PYTHONPATH

if [[ -d ~/.gem/ruby/2.8/bin ]] ; then
  export PATH=~/.gem/ruby/2.8/bin:$PATH
fi

if [[ -d $HOME/.rvm/bin ]] ; then
  export PATH=$PATH:$HOME/.rvm/bin
fi

########################################################
# Syntax highlighting in less
########################################################

# export LESSOPEN="| $(brew --prefix source-highlight)/bin/src-hilite-lesspipe.sh %s"
# export LESS=' -R '

########################################################
# Terminal Prompt
########################################################

function parse_git_branch() {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(git::\1) /'
}

function parse_svn_url() {
  svn info 2>/dev/null | grep -e '^URL*' | sed -e 's#^URL: *\(.*\)#\1#g '
}
function parse_svn_repository_root() {
  svn info 2>/dev/null | grep -e '^Repository Root:*' | sed -e 's#^Repository Root: *\(.*\)#\1\/#g '
}
function parse_svn_branch() {
  parse_svn_url | sed -e 's#^'"$(parse_svn_repository_root)"'##g' | awk -F / '{print "(svn::"$1 "/" $2 ") "}'
}

function store_exit_code() {
  EXIT_CODE=$?
}

function exit_code() {
  [[ "$EXIT_CODE" = "0" ]] && return
  echo -n "$EXIT_CODE "
}

PROMPT_COMMAND=store_exit_code

export PS1="\[\033[1;34m\][\$(date +%H:%M)] \[\033[1;36m\]\u@\h \w \[\033[1;32m\]\$(parse_git_branch)\$(parse_svn_branch)\[\033[1;31m\]\$(exit_code)\[\033[1;36m\]$\[\033[0m\] "

function gethost() {
  cat ~/.ssh/config | grep -A1 -E "$1\$" | grep HostName | awk '{print $2}'
}

function getip() {
  host $(gethost $1) | awk '{print $4}'
}

########################################################
# Autocomplete
########################################################

function _complete_git() {
  if [[ -d .git ]]; then
    branches=`git branch -a | cut -c 3-`
    tags=`git tag`
    cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "${branches} ${tags}" -- ${cur}) )
  fi
}
# complete -F _complete_git "git checkout"

# bash-completion mac ports package
if [ -f /opt/local/etc/bash_completion ]; then
  source /opt/local/etc/bash_completion
fi

if [[ -f ~/bin/autocomplete_ssh_config.py ]]; then
  complete -W "$(~/bin/autocomplete_ssh_config.py)" ssh
fi

########################################################
# Aliases
########################################################

# -- ls aliases

alias ls="ls -G"
alias ll="ls -ltr"

# -- side-by-side diff

alias ydiff="diff -y --suppress-common-lines"

# -- Git aliases

alias gs="git status"
alias gd="git diff"
alias gco="git checkout"
alias grom="git rebase origin/master"

function gh() {
  git status 2>&1 > /dev/null && cd `git rev-parse --show-toplevel`
}

function git_lineschanged() {
  git log --numstat --pretty="%H" $1 | awk 'NF==3 {plus+=$1; minus+=$2} END {printf("+%d, -%d\n", plus, minus)}'
}

# -- Useful one-liners

function logtail() {
  tail -F "`ls -t | head -1`"
}

function e() {
  echo "/Applications/Aquamacs.app/Contents/MacOS/bin/emacsclient $1 &"
  /Applications/Aquamacs.app/Contents/MacOS/bin/emacsclient $1 &
}

alias nt="nosetests --nocapture --nologcapture --tests"

alias serve="python -m SimpleHTTPServer 8000"

alias be="bundle exec"

########################################################
# Load non-version controlled (private) bashrc files
########################################################

for f in ~/.bash_ext_*; do
  source $f
done

