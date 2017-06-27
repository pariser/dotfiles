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

if [[ -d /usr/local/share/npm/bin ]] ; then
  export PATH=/usr/local/share/npm/bin:$PATH
fi

if [[ -d $HOME/.rvm/bin ]] ; then
  export PATH=$PATH:$HOME/.rvm/bin
fi

export PYTHONPATH=~/lib:$PYTHONPATH

export GOPATH=~/dev/golang
export PATH=$PATH:$GOPATH/bin

export PATH=/usr/local/Qt5.5.1/5.5/clang_64/bin:$PATH

########################################################
# Bash Completion
########################################################

if [ -f $(brew --prefix)/etc/bash_completion ]; then
  source $(brew --prefix)/etc/bash_completion
fi

if [ -f ~/lib/rake ]; then
  source ~/lib/rake
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
    git status > /dev/null 2>&1 || return 0
    branch=$(git rev-parse --abbrev-ref HEAD)
    [[ ${#branch} -gt 20 ]] && branch="$(echo $branch | cut -c1-19)…"pwd
    # TODO: speed these up on very large repositories
    # status=$(git_sync_status_prompt)
    # commits=$(git_commits_out_of_sync)
    status=""
    commits=""
    echo -e "${GREEN}(git::${branch}${status}${commits}${GREEN})${RESTORE} "
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

PROMPT_COMMAND="store_exit_code; $PROMPT_COMMAND"

export PS1="${BOLDBLUE}[\$(date +%H:%M)] ${CYAN}\u@${BOLDCYAN}\h ${CYAN}\w \$(git_branch_string)\$(parse_svn_branch)${BOLDRED}\$(exit_code)${BOLDCYAN}\$${RESTORE} "

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

alias hack-the-planet="afplay $HOME/dev/learnup/work-advice/misc/hack-the-planet.mp3 &"

# -- ls aliases

alias ls="ls -G"
alias ll="ls -ltr"

# -- side-by-side diff

alias ydiff="diff -y --suppress-common-lines"

# -- Git aliases

alias git=hub
alias gs="git status"
alias gd="git diff"
alias gco="git checkout"
alias grom="git rebase origin/master"
alias isgit="git status &> /dev/null"

alias gist_diff="isgit && (git diff | gist -p -t diff | xargs open)"
alias atom_diff="git diff | tmpin atom"

function github() {
  ref=$1
  github_url=$(git remote -v | awk '/origin.*fetch/{print $2}' | sed -E -e 's@:@/@' -e 's#(git@|git://)#http://#' -e 's#\.git$##')
  if [[ -n "$ref" ]]; then
    if [[ $ref =~ ^#\[0-9\]+$ ]]; then
      github_url="$github_url/pull/$ref"
    else
      github_url="$github_url/commit/$ref"
    fi
  else
    github_branch=$(git rev-parse --abbrev-ref HEAD)
    if [[ "_$github_branch" == "_master" ]]; then
      # echo "master"
      github_url="$github_url/commits/master"
    else
      # echo "branch"
      github_url="$github_url/commits/$github_branch"
    fi
  fi
  echo $github_url
  open $github_url | head -n1
}

function gh() {
  isgit && cd `git rev-parse --show-toplevel` || return $?
}

function git_lineschanged() {
  git log --numstat --pretty="%H" $1 | awk 'NF==3 {plus+=$1; minus+=$2} END {printf("+%d, -%d\n", plus, minus)}'
}

# -- Git completion for "gco" alias

__git_complete gco _git_checkout

# -- Useful one-liners

function logtail() {
  tail -F "`ls -t | head -1`"
}

alias now="ruby -e 'puts Time.now.to_i'"

alias nt="nosetests --nocapture --nologcapture --tests"

alias serve="python -m SimpleHTTPServer 8000"

alias be="bundle exec"

alias mlt="tail -f /usr/local/var/log/mongodb/mongo.log"

alias aquamacs="/Applications/Aquamacs.app/Contents/MacOS/Aquamacs"
alias aquamacs_byte_compile="aquamacs -Q -L . -batch -f batch-byte-compile"

function pushd() {
  command pushd "$@" > /dev/null
}

function popd() {
  command popd "$@" > /dev/null
}

alias flush_memcached="echo \"flush_all\" | nc localhost 11211"

alias showFinderDotfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hideFinderDotfiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'

alias nginx-start="sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.nginx.plist"
alias nginx-stop="sudo launchctl unload /Library/LaunchDaemons/homebrew.mxcl.nginx.plist"
alias nginx-restart="nginx-stop && nginx-start"

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

# added by travis gem
[ -f $HOME/.travis/travis.sh ] && source $HOME/.travis/travis.sh
