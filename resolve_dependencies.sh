#!/bin/bash

echo '************************************************************'

# Install Homebrew
BREWVERSION=`brew -v`
if [[ $? == 0 ]] ; then
  echo "Already found Homebrew installed. Not installing again!"
else
  echo "Installing Homebrew"
  ruby -e "$(curl -fsSL https://raw.github.com/gist/323731)"
fi

echo '************************************************************'

brew install node
npm config set prefix /usr/local
npm install -g jslint

echo '************************************************************'

# Install bash completion
brew install bash-completion

echo '************************************************************'

# Install Homebrew formulae
for FORMULA in source-highlight ; do
  BREWFILES=`brew list $FORMULA`
  if [[ $? == 0 ]] ; then
    echo "Already found Homebrew formula $FORMULA installed. Not installing again!"
  else
    echo "Installing Homebrew formula $FORMULA"
    sudo brew install $FORMULA
  fi
done

echo '************************************************************'

exit 0
