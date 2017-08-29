# Andrew Pariser's dotfiles

## Why You May Care...

Here are some of the highlights you may find inside this dotfiles directory:

### `git branch-details`

The script [`bin/git-branch-details`](https://github.com/pariser/dotfiles/blob/master/bin/git-branch-details)
shows you all of your git branches, whether they're tracking upstream, how many
commits ahead/behind this branch is from its upstream, and if it's been merged
into origin/master. When installed correctly on your path, you can call execute
it as you would any other git command.

### `PS1` shell variable

The shell variable [`PS1`](https://github.com/pariser/dotfiles/blob/master/bashrc#L191)
informs your terminal shell what to print before your command prompt. My `PS1`
includes information about your git branch and the error code of your most
recently executed shell command (if non-zero).

### Some aliases and one-liners

Everyone has their aliases and one-line shell functions. As defined in
my [bashrc](https://github.com/pariser/dotfiles/blob/master/bashrc),
my favorite are:
```
gh      git home
        cd to the root of your git repository (when applicable)

ydiff   side-by-side diff
        named after the -y argument, and it suppresses common lines too
```


## Setup

```sh
# Clone repository
git clone git@github.com:pariser/dotfiles.git
cd dotfiles

# Install dependencies
gem install --no-ri --no-rdoc colored

# Set up directory structure & link files
./install.rb
```

## TODO

_Nothing to see here..._

## Notes On Naming

### Computers

Named after [Godzilla monsters](http://en.wikipedia.org/wiki/List_of_kaiju "Wikipedia - List of Kaiju")
* `mothra`
* `rodan`

Named after [magicians](http://en.wikipedia.org/wiki/List_of_magicians "Wikipedia - List of Magicians")
* `copperfield`
* `dynamo`

Named after comic book characters (inspired by
[Captain Dynamo](http://en.wikipedia.org/wiki/Captain_Dynamo_%28comics%29 "Wikipedia - Captain Dynamo (comics))"))

* `widowmaker` &ndash; the assassin who killed Captain Dynamo
