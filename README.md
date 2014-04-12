festapp-ios
===========

[![Build Status](https://travis-ci.org/futurice/festapp-ios.svg)](https://travis-ci.org/futurice/festapp-ios)


## Bootstrapping

You'll need [xctool](https://github.com/facebook/xctool)
You can install it with
```sh
brew install xctool
```
or if that doesn't work than try the latest version with
````sh
brew install --HEAD xctool
```

For more information, check [#328](https://github.com/facebook/xctool/issues/328) [#331](https://github.com/facebook/xctool/pull/331).


```sh
# Update submodules (also initializes if needed)
git submodule update --init --recursive

# Bootstrap ReactiveCocoa
ReactiveCocoa/script/bootstrap
```

## Fetching newest content

```sh
rake fetch_content
```

## Run tests

You can run tests once with:

```sh
rake test
```

Or you can use guard to watch changed files and notify results:

```sh
bin/guard
```
