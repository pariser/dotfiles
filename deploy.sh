#!/bin/bash

# Get the path of the deploy script
LOCALPATH="$( cd "$( dirname "$0" )" && pwd )"

# Link the dotfiles that belong in ~/
for FILE in profile bashrc gitconfig gitignore screenrc emacs emacs.d vimrc ackrc; do
  if [[ -f ~/.$FILE ]] || [[ -d ~/.$FILE ]] && ! [[ -L ~/.$FILE ]] ; then
    echo "Not linking file $LOCALPATH/$FILE -- ~/.$FILE already exists"
  elif [[ -L ~/.$FILE ]] ; then
    echo "~/.$FILE is already a symbolic link. Skipping."
  else
    ln -s $LOCALPATH/$FILE ~/.$FILE
  fi 
done

# Make bin,dev,lib directories
for DIR in ~/bin ~/dev ~/lib ; do
  if ! [[ -d $DIR ]] ; then
    mkdir -p $DIR
  fi
done

# Link the script files that should be in my path
for FILE in $LOCALPATH/bin/* ; do
  BASENAME="$( basename "$FILE" )"
  if [[ -f ~/bin/$BASENAME ]] && ! [[ -L ~/bin/$BASENAME ]] ; then
    echo "Not linking file $LOCALPATH/bin/$BASENAME -- ~/bin/$BASENAME already exists"
  elif [[ -L ~/bin/$BASENAME ]] ; then
    echo "~/bin/$BASENAME is already a symbolic link. Skipping."
  else
    ln -s $LOCALPATH/bin/$BASENAME ~/bin/$BASENAME
  fi
done

source ~/.bashrc

