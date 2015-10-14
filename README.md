festapp-ios
===========

[![Build Status](https://travis-ci.org/futurice/festapp-ios.svg)](https://travis-ci.org/futurice/festapp-ios)


## Bootstrapping

You'll need [xctool](https://github.com/facebook/xctool). You can install it with

```sh
brew install xctool
```
or if that doesn't work than try the latest version with
````sh
brew install --HEAD xctool
```

For more information, check [#328](https://github.com/facebook/xctool/issues/328) [#331](https://github.com/facebook/xctool/pull/331).

ReactiveCocoa is managed using Carthage. To fetch it, do

```sh
carthage bootstrap

```

AFNetworking is still included as a git submodule. To fetch it, do

```sh
# Update submodules (also initializes if needed)
git submodule update --init --recursive

```
