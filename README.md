festapp-ios
===========


## Bootstrapping

You'll need [xctool](https://github.com/facebook/xctool)
You can install it with
```sh
brew install xctool
```
or if that doesn't work than check [#328](https://github.com/facebook/xctool/issues/328) [#331](https://github.com/facebook/xctool/pull/331).

For convenience a binary of xctool is included in Tools/xctool directory and you
can copy it for example to /usr/local/bin directory if you dare to use it. We
promise it has no backdoors or other code that the source distribution wouldn't
have. Sorry about the hassle, let's hope Homebrew fixes their scripts on OS X
10.9 soon.


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
