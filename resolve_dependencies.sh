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

# Compile pymacs
pushd $LOCALPATH/dependencies/Pymacs > /dev/null
$EMACS -Q -L . -batch -f batch-byte-compile pymacs.el
popd > /dev/null

if [[ -f $LOCALPATH/emacs.d/site-lisp/pymacs.el ]]; then
  echo "Pymacs emacs lisp file already deployed; skipping"
else
  echo "Linking Pymacs emacs lisp file"
  ln -s $LOCALPATH/dependencies/Pymacs/pymacs.el $LOCALPATH/emacs.d/site-lisp/pymacs.el
  ln -s $LOCALPATH/dependencies/Pymacs/pymacs.elc $LOCALPATH/emacs.d/site-lisp/pymacs.elc
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

# Install yasnippet for emacs
if [[ -d $LOCALPATH/dependencies/yasnippet ]] ; then
  echo "Alread found yasnippet subversion repository; running svn update"
  pushd $LOCALPATH/dependencies/yasnippet > /dev/null
  svn update
  popd > /dev/null
else
  echo "Checking out newest verison of yasnippet from Google Code"
  svn checkout http://yasnippet.googlecode.com/svn/trunk/ $LOCALPATH/dependencies/yasnippet
fi

# Compile yasnippet emacs lisp files
pushd $LOCALPATH/dependencies/yasnippet > /dev/null
$EMACS -Q -L . -batch -f batch-byte-compile yasnippet.el dropdown-list.el
popd > /dev/null

# Link yasnippet
if [[ -f $LOCALPATH/emacs.d/site-lisp/yasnippet ]] ; then
  echo "yasnippet has been deployed; skipping"
elif ! [[ -L $LOCALPATH/emacs.d/site-lisp/yasnippet ]] ; then
  echo "Linking yasnippet"
  ln -s $LOCALPATH/dependencies/yasnippet $LOCALPATH/emacs.d/site-lisp/yasnippet
fi

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

# Compile js-beautify.el
pushd $LOCALPATH/dependencies/js-beautify.el > /dev/null
$EMACS -Q -L . -batch -f batch-byte-compile js-beautify.el
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

# Compile haml-mode
pushd $LOCALPATH/dependencies/haml-mode > /dev/null
$EMACS -Q -L . -batch -f batch-byte-compile haml-mode.el
popd > /dev/null

# Install haml-mode
if [[ -f $LOCALPATH/emacs.d/site-lisp/haml-mode.el ]] ; then
  echo "haml-mode.el has been deployed; skipping"
elif ! [[ -L $LOCALPATH/emacs.d/site-lisp/haml-mode.el ]] ; then
  echo "Linking haml-mode.el"
  ln -s $LOCALPATH/dependencies/haml-mode/haml-mode.el $LOCALPATH/emacs.d/site-lisp/haml-mode.el
  ln -s $LOCALPATH/dependencies/haml-mode/haml-mode.elc $LOCALPATH/emacs.d/site-lisp/haml-mode.elc
fi

echo '************************************************************'

# Compile yaml-mode
pushd $LOCALPATH/dependencies/yaml-mode > /dev/null
$EMACS -Q -L . -batch -f batch-byte-compile yaml-mode.el
popd > /dev/null

# Install yaml-mode
if [[ -f $LOCALPATH/emacs.d/site-lisp/yaml-mode.el ]] ; then
  echo "yaml-mode.el has been deployed; skipping"
elif ! [[ -L $LOCALPATH/emacs.d/site-lisp/yaml-mode.el ]] ; then
  echo "Linking yaml-mode.el"
  ln -s $LOCALPATH/dependencies/yaml-mode/yaml-mode.el $LOCALPATH/emacs.d/site-lisp/yaml-mode.el
  ln -s $LOCALPATH/dependencies/yaml-mode/yaml-mode.elc $LOCALPATH/emacs.d/site-lisp/yaml-mode.elc
fi

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
# pushd $LOCALPATH/dependencies/scss-mode > /dev/null
# $EMACS -Q -L $LOCALPATH/dependencies/haml-mode -L . -batch -f batch-byte-compile scss-mode.el
# popd > /dev/null

# Install scss-mode
if [[ -f $LOCALPATH/emacs.d/site-lisp/scss-mode.el ]] ; then
  echo "scss-mode.el has been deployed; skipping"
elif ! [[ -L $LOCALPATH/emacs.d/site-lisp/scss-mode.el ]] ; then
  echo "Linking scss-mode.el"
  ln -s $LOCALPATH/dependencies/scss-mode/scss-mode.el $LOCALPATH/emacs.d/site-lisp/scss-mode.el
  # ln -s $LOCALPATH/dependencies/scss-mode/scss-mode.elc $LOCALPATH/emacs.d/site-lisp/scss-mode.elc
fi

echo '************************************************************'

# Compile rinari
pushd $LOCALPATH/dependencies/rinari > /dev/null
$EMACS -Q -L . -batch -f batch-byte-compile rinari.el rinari-merb.el
popd > /dev/null

# Install rinari.el
if [[ -f $LOCALPATH/emacs.d/site-lisp/rinari.el ]] ; then
  echo "rinari.el has been deployed; skipping"
elif ! [[ -L $LOCALPATH/emacs.d/site-lisp/rinari.el ]] ; then
  echo "Linking rinari.el"
  ln -s $LOCALPATH/dependencies/rinari/rinari.el $LOCALPATH/emacs.d/site-lisp/rinari.el
  ln -s $LOCALPATH/dependencies/rinari/rinari.elc $LOCALPATH/emacs.d/site-lisp/rinari.elc
  ln -s $LOCALPATH/dependencies/rinari/rinari-merb.el $LOCALPATH/emacs.d/site-lisp/rinari-merb.el
  ln -s $LOCALPATH/dependencies/rinari/rinari-merb.elc $LOCALPATH/emacs.d/site-lisp/rinari-merb.elc
  ln -s $LOCALPATH/dependencies/rinari/util/ruby-compilation.el $LOCALPATH/emacs.d/site-lisp/ruby-compilation.el
fi

echo '************************************************************'

exit 0

