# Andrew Pariser's dotfiles

## Usage

* Clone at

  ```
  git clone git@github.com:pariser/dotfiles.git
  ```

* Download the git submodules

  ```
  git submodule update --recursive
  ```

* Set up directory structure & link files

  ```
  ./deploy.sh
  ```

* Update all the dependencies & packages

  ```
  ./resolve_dependencies.sh
  ```

## TODO

* Add atom config
* Merge `resolve_dependencies.sh` and `deploy.sh`
* Replace installation / dependencies files with single `install` script (in python or ruby?)
* Load newest versions of git submodules on running dependencies.sh

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
