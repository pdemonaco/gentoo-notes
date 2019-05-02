# YouCompleteMe Setup

https://github.com/Valloric/YouCompleteMe

# Simple Config

It's way easier to just use the external libraries for this module. Basically, just follow the [install guide](https://github.com/Valloric/YouCompleteMe#linux-64-bit) from YCM. Before running this there are likely some dependencies:

```bash
# Here's some you might need
emerge -avt net-libs/nodejs dev-lang/rust dev-lang/go
```

# Old Config
## Prep the build environment

Then you'll need some utilities to build. I've installed these natively in my system, however, it may be prudent to leave them out of world.


```bash
cd /etc
echo ">=sys-devel/clang-3.8 ~amd64" >> /etc/portage/package.accept_keywords/youcompleteme
echo ">=sys-devel/llvm-3.8 ~amd64" >> /etc/portage/package.accept_keywords/youcompleteme
echo "sys-devel/llvm clang" >> /etc/portage/package.use/youcompleteme
git add /etc/portage/package.use/youcompleteme
git add /etc/portage/package.accept_keywords/youcompleteme
emerge -avt dev-cpp/gtest dev-cpp/gmock
```

## .vimrc

Add the components to your .vimrc 

```shell
Plugin 'Valloric/YouCompleteMe'
let g:ycm_confirm_extra_conf = 0
set omnifunc=syntaxcomplete#Complete
```

After you get it added to your .vimrc ensure that it's updated
to the latest version via `VundleInstall` or `VundleUpdate`

## Build

Switch to the installation directory and begin the install!

```bash
cd ~/.vim/bundle/YouCompleteMe/
python install.py --clang-completer --system-libclang
```

And that's it.
