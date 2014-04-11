festapp-ios
===========


## Bootstrapping

You'll need [xctool](https://github.com/facebook/xctool)
You can install it with
```sh
brew install xctool
```
or if that doesn't work than check [#328](https://github.com/facebook/xctool/issues/328) [#331](https://github.com/facebook/xctool/pull/331).


```sh
# Init submodules
git submodule init

# Fetch submodules (ReactiveCocoa, ...)
git submodule update --recursive

# Bootstrap ReactiveCocoa
ReactiveCocoa/script/bootstrap
```

## Fetching newest content

```sh
./fetch-content.sh
```
