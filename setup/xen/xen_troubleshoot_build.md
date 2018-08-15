# Overview

This error pops up for xen-4.9.2 on my environment:

```bash
efi/buildid.o: file not recognized: File format is ambiguous
efi/buildid.o: matching formats: coff-x86-64 pe-x86-64
```

Some additional detail is provided [here](https://forums.gentoo.org/viewtopic-t-1072366.html). Apparently it's something janky in either binutils handling of the file or Xen's Makefile structure.

# Patching

1. Unpack Xen 4.9.2.

    ```bash
    PACKAGE="app-emulation/xen"
    BUILD="xen-4.9.2"
    sudo ebuild $(portageq get_repo_path / gentoo)/"${PACKAGE}/${BUILD}.ebuild" clean unpack
    ```
2. Become root and move to the directory.

    ```bash
    sudo -i
    BUILD="xen-4.9.2"
    cd "/var/tmp/portage/app-emulation/${BUILD}/work/${BUILD}"
    ```
3. Create a git repo and commit everything.

    ```bash
    git init
    git add .
    git commit
    ```
4. Make the changes to xen/arch/x86/Makefile
5. Add patch to the gentoo portage tree.
