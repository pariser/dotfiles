## -*- mode: Shell-script; -*-

########################################################
# History
########################################################

# See: http://unix.stackexchange.com/questions/1288/preserve-bash-history-in-multiple-terminal-windows#answer-48113

export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it

# # Save and reload the history after each command finishes
# export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

########################################################
# Path
########################################################

export PATH=~/bin:$PATH
export PATH=./node_modules/.bin:$PATH
export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/lib/node_modules/bin:$PATH
export PATH=$PATH:/usr/local/opt/go/libexec/bin # brew info go
export PATH=$PATH:/usr/local/sbin

# NPM
if [[ -d /usr/local/share/npm/bin ]]; then
  export PATH=/usr/local/share/npm/bin:$PATH
fi

# Python
export PYTHONPATH=~/lib:$PYTHONPATH

# Go
export GOPATH=~/dev/golang
export PATH=$PATH:$GOPATH/bin

export PATH=/usr/local/Qt5.5.1/5.5/clang_64/bin:$PATH

########################################################
# Sourced external packages
########################################################

[ -f ~/lib/rake ] && source ~/lib/rake

# added by travis gem
[ -f $HOME/.travis/travis.sh ] && source $HOME/.travis/travis.sh

########################################################
# NVM
########################################################

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

########################################################
# Bash Completion
########################################################

which brew 2>1 &> /dev/null
if [ $? -eq 0 && -f $(brew --prefix)/etc/bash_completion ]; then
  source $(brew --prefix)/etc/bash_completion
fi

########################################################
# Syntax highlighting in less
########################################################

# export LESSOPEN="| $(brew --prefix source-highlight)/bin/src-hilite-lesspipe.sh %s"
# export LESS=' -R '

########################################################
# Terminal Colors
########################################################

RESTORE='\033[0m'

RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
PURPLE='\033[00;35m'
CYAN='\033[00;36m'
LIGHTGRAY='\033[00;37m'

BOLDRED='\033[1;31m'
BOLDGREEN='\033[1;32m'
BOLDYELLOW='\033[1;33m'
BOLDBLUE='\033[1;34m'
BOLDPURPLE='\033[1;35m'
BOLDCYAN='\033[1;36m'
BOLDLIGHTGRAY='\033[1;37m'

function test_colors(){
    echo -e "${GREEN}Hello ${CYAN}THERE${RESTORE} Restored here ${LCYAN}HELLO again${RESTORE}"
}

########################################################
# Terminal Prompt
########################################################

function git_commits_out_of_sync() {
    git status > /dev/null 2>&1 || return 0

    upstream=$(git upstream)
    has_upstream=$?
    if [[ "$has_upstream" -ne 0 ]]; then
        return 0
    fi

    a=$(git rev-list --left-right $(git head)...${upstream} | grep '<' | wc -l | tr -d ' ')
    b=$(git rev-list --left-right $(git head)...${upstream} | grep '>' | wc -l | tr -d ' ')
    if [[ "$a" -gt 0 && "$b" -gt 0 ]]; then
        echo -e " ${YELLOW}+${a}${RESTORE}/${PURPLE}${b}"
    elif [[ "$a" -gt 0 ]]; then
        echo -e " ${YELLOW}+${a}"
    elif [[ "$b" -gt 0 ]]; then
        echo -e " ${PURPLE}-${b}"
    else
        echo ""
    fi
}

function git_files_out_of_sync() {
    git status > /dev/null 2>&1 || return 0

    # return is one of:
    # 0 = branch in sync
    # 1 = branch modified
    # 2 = untracked files
    # 3 = changes to be committed

    STATUS=0

    git diff --no-ext-diff --quiet || STATUS=1

    if [[ "$STATUS" -eq 0 ]]; then
        STATUS=`git ls-files --exclude-standard --others | wc -l`
        if [[ "$STATUS" -ne 0 ]]; then STATUS=2; fi
    fi

    if [[ "$STATUS" -eq 0 ]]; then
        git diff --cached --no-ext-diff --quiet || STATUS=3
    fi

    return $STATUS
}

function git_sync_status_prompt() {
    git status > /dev/null 2>&1 || return 0

    git_files_out_of_sync
    CODE=$?

    if [[ "x$OSTYPE" == "xdarwin12" ]]; then
        if [[ "$CODE" -eq 3 ]]; then
            echo " 🔶 "
        elif [[ "$CODE" -eq 2 ]]; then
            echo " ❔ "
        elif [[ "$CODE" -eq 1 ]]; then
            echo " ❌ "
        elif [[ "$CODE" -eq 0 ]]; then
            echo " ✅ "
        fi
    fi
}

function git_branch_string() {
    #  First, check if we're even within a git repository
    inside_work_tree=$(git rev-parse --is-inside-work-tree 2> /dev/null)
    [[ "$?" != "0" ]] && return

    #  Get the branch associated with HEAD
    branch=$(git rev-parse --abbrev-ref HEAD)
    [[ ${#branch} -gt 20 ]] && branch="$(echo $branch | cut -c1-19)…"

    # TODO: speed these up on very large repositories
    # status=$(git_sync_status_prompt)
    # commits=$(git_commits_out_of_sync)
    status=""
    commits=""

    echo "(git::${branch}${status}${commits}) "
}

function store_exit_code() {
  EXIT_CODE=$?
}

function exit_code() {
  [[ "$EXIT_CODE" = "0" ]] && return
  echo -n "$EXIT_CODE "
}

function store_tab_title() {
  echo -ne "\033]0;${PWD/#$HOME/~}\007"
}

PROMPT_COMMAND="store_exit_code; $PROMPT_COMMAND"

if [ -z ${DOCKER_CONTAINER_NAME+x} ]; then
  echo "USING DOCKER SETTINGS"
  USER="🐳"
  HOSTNAME=$DOCKER_CONTAINER_NAME
  TIME_COLOR=$BOLDBLUE
  GIT=""
else
  echo "NOT USING DOCKER SETTINGS"
  USER="\u"
  HOSTNAME="\h"
  TIME_COLOR=$BOLDLIGHTGRAY
  GIT="\$(git_branch_string)"
fi

export PS1="\\[${TIME_COLOR}\\][\$(date +%H:%M)] \\[${CYAN}\\]${USER}@\\[${BOLDCYAN}\\]${HOSTNAME} \\[${CYAN}\\]\w \\[${GREEN}\\]${GIT}\\[${RESTORE}\\]\\[${BOLDRED}\\]\$(exit_code)\\[${BOLDCYAN}\\]\$\\[${RESTORE}\\] "

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

# Git completion for "gco" and "gsw" aliases
__git_complete gco _git_checkout
__git_complete gsw _git_checkout

########################################################
# Version Comparison
########################################################

[[ -f ~/.vercomp ]] && source ~/.vercomp

########################################################
# Aliases
########################################################

[[ -f ~/.aliases ]] && source ~/.aliases

########################################################
# Use N for node package management
########################################################

# N_PREFIX=${N_PREFIX-/usr/local}
# BASE_VERSIONS_DIR=$N_PREFIX/n/versions
#
# function n_installed_versions() {
#   find $BASE_VERSIONS_DIR -maxdepth 2 -type d \
#     | sed 's|'$BASE_VERSIONS_DIR'/||g' \
#     | egrep "/[0-9]+\.[0-9]+\.[0-9]+$" \
#     | sort -k 1 -k 2,2n -k 3,3n -t .
# }
#
# alias n_original=$(which n)
#
# function n() {
#   if [[ _$1 == '_ls' ]]; then
#     n_installed_versions
#   else
#     n_original $@
#   fi
#
#   npm_global_prefix=~/.n/$(node --version)
#
#   npm config set prefix
#
# }

########################################################
# Load non-version controlled (private) bashrc files
########################################################

for f in ~/.bash_ext_*; do
  if [[ ! ($f =~ \.swp$) ]]; then
    source $f
  fi
done
