set +e
set +x
########################################################
# Start the ZSH profiling tool (if ZSH_PROFILING is set)
########################################################

# To determine how long zsh takes to load:
#
#   time zsh -i -c exit
#
# To determine how long zsh takes to load with specific profiling tools:
#
#   time ZSH_PROFILING=1 zsh -i -c exit

[[ "_${ZSH_PROFILING}" = "_1" ]] && zmodload zsh/zprof

########################################################
# Oh My ZSH
########################################################

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="pariser"

HIST_STAMPS="yyyy-mm-dd"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

########################################################
# Other Configuration
########################################################

# -i - ignore case when searching (but respect case if search term contains uppercase letters)
# -X - do not clear screen on exit
# -F - exit if text is less then one screen long
# -R - was on by default on my system, something related to colors
export LESS=-iXFR

########################################################
# Path
########################################################

export PATH=~/bin:$PATH
export PATH=/opt/homebrew/bin:$PATH
export PATH=~/go/bin:$PATH

# pip-installed packages
python3 -m site &> /dev/null && PATH="$PATH:`python3 -m site --user-base`/bin"
python2 -m site &> /dev/null && PATH="$PATH:`python2 -m site --user-base`/bin"

########################################################
# Brew libraries
########################################################

# local OPENSSL_VERSION=1.0

# export PATH="/usr/local/opt/thrift@0.9/bin:$PATH"
# export PATH="/usr/local/opt/mysql@5.6/bin:$PATH"
export PATH=/usr/local/sbin:$PATH

# export PATH="/usr/local/opt/openssl@${OPENSSL_VERSION}/bin:$PATH"
# export LDFLAGS="-L/usr/local/opt/openssl@${OPENSSL_VERSION}/lib $LDFLAGS"

# # boost is used for the thrift compiler
# export LDFLAGS="-L/usr/local/opt/boost/lib $LDFLAGS"

# # Bison is used for the thrift compiler
# export PATH="/usr/local/opt/bison/bin:$PATH"
# export LDFLAGS="-L/usr/local/opt/bison/lib $LDFLAGS"

# # Readline is used for ruby install
# export LDFLAGS="-L/usr/local/opt/readline/lib $LDFLAGS"
# export CPPFLAGS="-I/usr/local/opt/readline/include $CPPFLAGS"

# # Make sure brew installed thrift is available to linkers
# export LDFLAGS="-L/usr/local/opt/thrift@0.9/lib $LDFLAGS"
# export CPPFLAGS="-I/usr/local/opt/thrift@0.9/include $CPPFLAGS"

# export LDFLAGS="-L/usr/local/opt/libffi/lib $LDFLAGS"
# export CPPFLAGS="-I/usr/local/opt/libffi/include $CPPFLAGS"

# export PKG_CONFIG_PATH="/usr/local/opt/libffi/lib/pkgconfig:$PKG_CONFIG_PATH"

########################################################
# rbenv
########################################################

rbenv --version 2>&1 &>/dev/null &&
  eval "$(rbenv init -)"

export PATH="$HOME/.rbenv/shims:$PATH"

# To link Ruby to Homebrew's OpenSSL 1.1...

# brew -v 2>&1 &>/dev/null &&
#   export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@${OPENSSL_VERSION})"

########################################################
# pyenv
########################################################

pyenv --version 2>&1 &>/dev/null &&
  eval "$(pyenv init --path)"

########################################################
# java
########################################################

function useJava8() {
  export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
  export PATH=$JAVA_HOME/bin:$PATH
}

function useJava17() {
  export JAVA_HOME=$(/usr/libexec/java_home -v 1.17)
  export PATH=$JAVA_HOME/bin:$PATH
}

useJava8

########################################################
# nvm
########################################################

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh" --no-use # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" --no-use # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# run `nvm use` when cd into root directory of project with `.nvmrc` file
autoload -U add-zsh-hook
load-nvmrc() {
  [[ -a .nvmrc ]] || return
  command -v nvm >/dev/null 2>&1 || return

  local node_version="$(nvm version > /dev/null)"
  local nvmrc_node_version=$(nvm version "$(cat .nvmrc)")

  if [ "$nvmrc_node_version" = "N/A" ]; then
    >&2 echo "nvm version "$(cat .nvmrc)" not installed; run `nvm install` to install it"
  elif [ "$nvmrc_node_version" != "$node_version" ]; then
    nvm use
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

########################################################
# Aliases
########################################################

[[ -f ~/.aliases ]] && source ~/.aliases

########################################################
# Load non-version controlled (private) zshrc files
########################################################

setopt NULL_GLOB # Don't complain if the glob pattern does not match any results
for f in ~/.zsh_ext_*; do
  if [[ ! ($f =~ \.swp$) ]]; then
    source $f
  fi
done
unsetopt NULL_GLOB # Restore default behavior about glob pattern

########################################################
# End the ZSH profiling tool
########################################################

[[ "_${ZSH_PROFILING}" = "_1" ]] && zprof

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
