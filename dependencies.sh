#!/bin/bash

EMACS="/Applications/Aquamacs.app/Contents/MacOS/Aquamacs"

# Get the path of the deploy script
LOCALPATH="$( cd "$( dirname "$0" )" && pwd )"

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

# Install Pymacs
IMPORTPYMACS=`echo 'import Pymacs' | python > /dev/null 2>&1`
if [[ $? == 0 ]] ; then
  echo "Pymacs python package already found; skipping python install"
else
  pushd $LOCALPATH/dependencies/Pymacs > /dev/null
  MAKECHECK=`make check 2>&1 >/dev/null`
  if [[ $? != 0 ]] ; then
    echo "Skipping Pymacs install; 'make check' failed:\n$MAKECHECK"
  else
    echo "Installing Pymacs"
    MAKEBUILD=`sudo make`
    if [[ $? == 0 ]] ; then
      MAKEINSTALL=`sudo make install`
    fi
  fi
  popd > /dev/null
fi

if [[ -f $LOCALPATH/emacs.d/site-lisp/pymacs.el ]]; then
  echo "Pymacs emacs lisp file already deployed; skipping"
else
  echo "Linking Pymacs emacs lisp file"
  ln -s $LOCALPATH/dependencies/Pymacs/pymacs.el $LOCALPATH/emacs.d/site-lisp/pymacs.el
fi

echo '************************************************************'

# Install pip
IMPORTPIP=`echo 'import pip' | python > /dev/null 2>&1`
if [[ $? == 0 ]] ; then
  echo "Pip already found; skipping"
else
  echo "Installing pip"
  sudo easy_install pip
fi

echo '************************************************************'

# for PACKAGE in pychecker ; do
#   IMPORT=`echo 'import $PACKAGE' | python > /dev/null 2>&1`
#   if [[ $? == 0 ]] ; then
#     echo "Python package $PACKAGE already found; skipping install"
#   else
#     sudo pip install $PACKAGE
#   fi
# done

echo '************************************************************'

if [[ -d $LOCALPATH/dependencies/yasnippet ]] ; then
  echo "Alread found yasnippet subversion repository; running svn update"
  pushd $LOCALPATH/dependencies/yasnippet > /dev/null
  svn update
  popd > /dev/null
else
  echo "Checking out newest verison of yasnippet from Google Code"
  svn checkout http://yasnippet.googlecode.com/svn/trunk/ $LOCALPATH/dependencies/yasnippet
fi

if [[ -f $LOCALPATH/emacs.d/site-lisp/yasnippet ]] ; then
  echo "yasnippet has been deployed; skipping"
elif ! [[ -L $LOCALPATH/emacs.d/site-lisp/yasnippet ]] ; then
  echo "Linking yasnippet"
  ln -s $LOCALPATH/dependencies/yasnippet $LOCALPATH/emacs.d/site-lisp/yasnippet
fi

pushd $LOCALPATH/dependencies/yasnippet > /dev/null
$EMACS -Q -L . -batch -f batch-byte-compile yasnippet.el dropdown-list.el
popd > /dev/null

echo '************************************************************'

for EMACSLIB in auto-complete egg ; do
  echo "Installing emacs library $EMACSLIB"

  pushd $LOCALPATH/dependencies/$EMACSLIB > /dev/null
  $EMACS -Q -L . -batch -f batch-byte-compile *.el
  popd > /dev/null

  if [[ -f $LOCALPATH/emacs.d/site-lisp/$EMACSLIB ]] ; then
    echo "$EMACSLIB has been deployed; skipping"
  elif ! [[ -L $LOCALPATH/emacs.d/site-lisp/$EMACSLIB ]] ; then
    echo "Linking $EMACSLIB"
    ln -s $LOCALPATH/dependencies/$EMACSLIB $LOCALPATH/emacs.d/site-lisp/$EMACSLIB
  fi
done
 
echo '************************************************************'

echo '************************************************************'

echo '************************************************************'

exit 0

