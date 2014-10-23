#!/bin/bash

EMACS="/Applications/Aquamacs.app/Contents/MacOS/Aquamacs"

# Get the path of the deploy script
LOCALPATH="$( cd "$( dirname "$0" )" && pwd )"
LOCALPATH=$HOME/dev/dotfiles
BUILDPATH=$LOCALPATH/build
SITELISPPATH=$LOCALPATH/emacs.d/site-lisp
DEPPATH=$LOCALPATH/dependencies

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

# Install bash completion & rake completion
brew install bash-completion
ln -s $LOCALPATH/dependencies/rake-completion/rake $(brew --prefix)/etc/bash_completion.d/rake
ln -s $LOCALPATH/dependencies/rake-completion/rake ~/lib/rake

echo '************************************************************'

FILES="yafolding.el"
OUTFILES="yafolding.elc"

(pushd $DEPPATH/yafolding > /dev/null) &&
 ($EMACS -Q -L . -batch -f batch-byte-compile $FILES) &&
 (mv $OUTFILES $LOCALPATH/build/) &&
 (rm $LOCALPATH/emacs.d/site-lisp/$OUTFILES) &&
 (ln -s $LOCALPATH/build/$OUTFILES $LOCALPATH/emacs.d/site-lisp/$OUTFILES) &&
 (popd > /dev/null)

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

FILES="pymacs.el"
OUTFILES="pymacs.elc"
DIRECTORY=$LOCALPATH/dependencies/Pymacs

# Change a setting in ppppconfig file for Aquamacs compatibility
(pushd $DIRECTORY > /dev/null &&
 cp ppppconfig.py ppppconfig.py.bak &&
 sed "s/^DEFADVICE_OK.*/DEFADVICE_OK = 'nil'/" ppppconfig.py.bak > ppppconfig.py &&
 popd > /dev/null)

(pushd $DIRECTORY > /dev/null) &&
 ($EMACS -Q -L . -batch -f batch-byte-compile $FILES) &&
 (mv $OUTFILES $LOCALPATH/build/) &&
 (rm $LOCALPATH/emacs.d/site-lisp/$OUTFILES) &&
 (ln -s $LOCALPATH/build/$OUTFILES $LOCALPATH/emacs.d/site-lisp/$OUTFILES) &&
 (popd > /dev/null)

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

# Install python packages
for PACKAGE in pyflakes ; do
  IMPORT=`echo "import $PACKAGE" | python > /dev/null 2>&1`
  if [[ $? == 0 ]] ; then
    echo "Python package $PACKAGE already found; skipping install"
  else
    echo "Installing python package $PACKAGE"
    sudo pip install $PACKAGE
  fi
done

echo '************************************************************'

pushd $LOCALPATH/dependencies/yasnippet
$EMACS -Q -L . -batch -f batch-byte-compile yasnippet.el
mv yasnippet.elc $BUILDPATH
ln -s $BUILDPATH/yasnippet.elc $SITELISPPATH/yasnippet.elc

echo '************************************************************'

# Install emacs packages
for EMACSLIB in auto-complete egg pycomplete textmate mmm-mode ; do
  echo '************************************************************'
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

# Install pycomplete
PYCOMPLETE=`echo 'import pycomplete' | python > /dev/null 2>&1`
if [[ $? == 0 ]] ; then
  echo "pycomplete already installed to python; skipping."
elif [[ -f ~/lib/pycomplete.py ]] ; then
  echo "pycomplete found in ~/lib but not found by python. Check that ~/lib is in your PYTHONPATH"
else
  echo "Linking pycomplete.py"
  ln -s $LOCALPATH/dependencies/pycomplete/pycomplete.py ~/lib/pycomplete.py
fi


echo '************************************************************'

# Compile full-ack
pushd $LOCALPATH/dependencies/full-ack > /dev/null
$EMACS -Q -L . -batch -f batch-byte-compile full-ack.el
popd > /dev/null

# Install full-ack
if [[ -f $LOCALPATH/emacs.d/site-lisp/full-ack ]] ; then
  echo "full-ack has been deployed; skipping"
elif ! [[ -L $LOCALPATH/emacs.d/site-lisp/full-ack ]] ; then
  echo "Linking full-ack"
  ln -s $LOCALPATH/dependencies/full-ack/full-ack.el $LOCALPATH/emacs.d/site-lisp/full-ack.el
  ln -s $LOCALPATH/dependencies/full-ack/full-ack.elc $LOCALPATH/emacs.d/site-lisp/full-ack.elc
fi

echo '************************************************************'

# Compile mmm-mako
pushd $LOCALPATH/dependencies > /dev/null
$EMACS -Q -L . -batch -f batch-byte-compile mmm-mako.el
popd > /dev/null

# Install mmm-mako
if [[ -f $LOCALPATH/emacs.d/site-lisp/mmm-mako.el ]] ; then
  echo "mmm-mako has been deployed; skipping"
elif ! [[ -L $LOCALPATH/emacs.d/site-lisp/mmm-mako.el ]] ; then
  echo "Linking mmm-mako"
  ln -s $LOCALPATH/dependencies/mmm-mako.el $LOCALPATH/emacs.d/site-lisp/mmm-mako.el
  ln -s $LOCALPATH/dependencies/mmm-mako.elc $LOCALPATH/emacs.d/site-lisp/mmm-mako.elc
fi

echo '************************************************************'

sudo pip install jsbeautifier

# Compile js-beautify.el
pushd $LOCALPATH/dependencies/js-beautify.el > /dev/null
$EMACS -Q -L . -batch -f batch-byte-compile js-beautify.el
mv js-beautify.elc $BUILDPATH
ln -s $BUILDPATH/js-beautify.elc $SITELISPPATH/js-beautify.elc
popd > /dev/null

# Install js-beautify.el
if [[ -f $LOCALPATH/emacs.d/site-lisp/js-beautify.el ]] ; then
  echo "js-beautify.el has been deployed; skipping"
elif ! [[ -L $LOCALPATH/emacs.d/site-lisp/js-beautify.el ]] ; then
  echo "Linking js-beautify.el"
  ln -s $LOCALPATH/dependencies/js-beautify.el/js-beautify.el $LOCALPATH/emacs.d/site-lisp/js-beautify.el
  ln -s $LOCALPATH/dependencies/js-beautify.el/js-beautify.elc $LOCALPATH/emacs.d/site-lisp/js-beautify.elc
fi

echo '************************************************************'

# haml-mode
pushd $LOCALPATH/dependencies/haml-mode
$EMACS -Q -L . -batch -f batch-byte-compile haml-mode.el
mv haml-mode.elc $BUILDPATH
rm $SITELISPPATH/haml-mode.elc
ln -s $BUIDPATH/haml-mode.elc $SITELISPPATH/haml-mode.elc
popd

echo '************************************************************'

# yaml-mode
pushd $LOCALPATH/dependencies/yaml-mode > /dev/null
$EMACS -Q -L . -batch -f batch-byte-compile yaml-mode.el
mv yaml-mode.elc $BUILDPATH
ln -s $BUILDPATH/yaml-mode.elc $SITELISPPATH/yaml-mode.elc
popd > /dev/null

echo '************************************************************'

# # Compile sass-mode
# pushd $LOCALPATH/dependencies/sass-mode > /dev/null
# $EMACS -Q -L $LOCALPATH/dependencies/haml-mode -L . -batch -f batch-byte-compile sass-mode.el
# popd > /dev/null

# Install sass-mode
if [[ -f $LOCALPATH/emacs.d/site-lisp/sass-mode.el ]] ; then
  echo "sass-mode.el has been deployed; skipping"
elif ! [[ -L $LOCALPATH/emacs.d/site-lisp/sass-mode.el ]] ; then
  echo "Linking sass-mode.el"
  ln -s $LOCALPATH/dependencies/sass-mode/sass-mode.el $LOCALPATH/emacs.d/site-lisp/sass-mode.el
  # ln -s $LOCALPATH/dependencies/sass-mode/sass-mode.elc $LOCALPATH/emacs.d/site-lisp/sass-mode.elc
fi

echo '************************************************************'

# # Compile scss-mode

pushd $LOCALPATH/dependencies/scss-mode > /dev/null
$EMACS -Q -L . -batch -f batch-byte-compile scss-mode.el
mv scss-mode.elc $BUILDPATH
ln -s $BUILDPATH/scss-mode.elc $SITELISPPATH/scss-mode.elc
popd > /dev/null

# pushd $LOCALPATH/dependencies/scss-mode > /dev/null
# $EMACS -Q -L $LOCALPATH/dependencies/haml-mode -L . -batch -f batch-byte-compile scss-mode.el
# popd > /dev/null

# # Install scss-mode
# if [[ -f $LOCALPATH/emacs.d/site-lisp/scss-mode.el ]] ; then
#   echo "scss-mode.el has been deployed; skipping"
# elif ! [[ -L $LOCALPATH/emacs.d/site-lisp/scss-mode.el ]] ; then
#   echo "Linking scss-mode.el"
#   ln -s $LOCALPATH/dependencies/scss-mode/scss-mode.el $LOCALPATH/emacs.d/site-lisp/scss-mode.el
#   # ln -s $LOCALPATH/dependencies/scss-mode/scss-mode.elc $LOCALPATH/emacs.d/site-lisp/scss-mode.elc
# fi

echo '************************************************************'

# Rinari, no compilation required
ln -s $LOCALPATH/dependencies/rinari $SITELISPPATH/rinari

echo '************************************************************'

# Auto-complete
pushd $LOCALPATH/dependencies/auto-complete > /dev/null
git submodule init
git submodule update

# Auto-complete dependency #2 (popup)
pushd lib/popup/ > /dev/null
$EMACS -Q -L . -batch -f batch-byte-compile popup.el
mv popup.elc $BUILDPATH
ln -s $BUILDPATH/popup.elc $SITELISPPATH/popup.elc
popd > /dev/null


echo '************************************************************'

exit 0
