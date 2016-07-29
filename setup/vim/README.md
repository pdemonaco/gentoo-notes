
# YouCompleteMe Setup

https://github.com/Valloric/YouCompleteMe

## Prep the build environment

Then you'll need some utilites to build. I've installed these natively in my system, however, it may be prudent to leave them out of world.


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
cd "~/.vim/bundle/YouCompleteMe/
python install.py --clang-completer --system-libclang
```

And that's it.
