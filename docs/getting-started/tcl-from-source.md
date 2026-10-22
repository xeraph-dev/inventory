# Building Tcl and Tk from source

How to compile static Tcl/Tk 9.1, tcllib and tklib and install them under `~/opt`, which is the layout [Setup](setup.md) expects.

Currently covered: **macOS arm64 and macOS x86_64, both built on an arm64 Mac**.

## Why from source

The app ships as a single executable (see [Building](building.md)). That needs a
`wish` with Tcl and Tk linked statically and zipfs enabled, which is not what
the official binary distributions provide.

## Prerequisites

- Xcode command line tools (`xcode-select --install`).
- The Tcl 9.1 and Tk 9.1 source tarballs, extracted as `tcl9.1-src/` and `tk9.1-src/`.
- For the x86_64 build: Rosetta 2 (`softwareupdate --install-rosetta`).

The `sqlite3` Tcl package is bundled in the Tcl tarball, so installing Tcl also
installs it (as `lib/sqlite3.53.4` under the prefix). Nothing extra to build.

## macOS arm64

Set the minimum macOS version for everything you compile in this shell:

```sh
export MACOSX_DEPLOYMENT_TARGET=11.0
```

11.0 is the first macOS release that runs on Apple silicon, so it is the lowest
possible target for arm64 binaries.

### Tcl

```sh
cd tcl9.1-src/unix
```

```sh
./configure --disable-shared --enable-zipfs \
    --prefix=$HOME/opt/tcl/9.1/osx/arm64 \
    CFLAGS="-mmacosx-version-min=11.0" LDFLAGS="-mmacosx-version-min=11.0"
```

```sh
make -j$(sysctl -n hw.ncpu) install
```

### Tk

Tk must be configured against the Tcl you just installed:

```sh
cd tk9.1-src/unix
```

```sh
./configure --disable-shared --enable-zipfs --enable-aqua \
    --prefix=$HOME/opt/tcl/9.1/osx/arm64 \
    --with-tcl=$HOME/opt/tcl/9.1/osx/arm64/lib \
    CFLAGS="-mmacosx-version-min=11.0" LDFLAGS="-mmacosx-version-min=11.0"
```

```sh
make -j$(sysctl -n hw.ncpu) install
```

### Check

```sh
~/opt/tcl/9.1/osx/arm64/bin/wish9.1
```

A Tk window should open. In its console, `info patchlevel` should print `9.1.x`.

## macOS x86_64 (from arm64)

Same steps as arm64, with three differences:

- The prefix is `$HOME/opt/tcl/9.1/osx/x86_64` (and the Tk `--with-tcl` path follows it).
- Every command (`./configure` and `make`) is prefixed with `arch -x86_64`, so it runs under Rosetta.
- `./configure` gets `--enable-64bit`.

Start from a clean source tree (`make distclean`) or a fresh extraction of the
tarballs, so nothing from the arm64 build is reused.

```sh
export MACOSX_DEPLOYMENT_TARGET=11.0

# Tcl
cd tcl9.1-src/unix
arch -x86_64 ./configure --disable-shared --enable-zipfs --enable-64bit \
    --prefix=$HOME/opt/tcl/9.1/osx/x86_64 \
    CFLAGS="-mmacosx-version-min=11.0" LDFLAGS="-mmacosx-version-min=11.0"
arch -x86_64 make -j$(sysctl -n hw.ncpu) install

# Tk
cd tk9.1-src/unix
arch -x86_64 ./configure --disable-shared --enable-zipfs --enable-aqua --enable-64bit \
    --prefix=$HOME/opt/tcl/9.1/osx/x86_64 \
    --with-tcl=$HOME/opt/tcl/9.1/osx/x86_64/lib \
    CFLAGS="-mmacosx-version-min=11.0" LDFLAGS="-mmacosx-version-min=11.0"
arch -x86_64 make -j$(sysctl -n hw.ncpu) install
```

Check it with `arch -x86_64 ~/opt/tcl/9.1/osx/x86_64/bin/wish9.1`, and
`file ~/opt/tcl/9.1/osx/x86_64/bin/wish9.1` should report `x86_64`.

## Flags

| Flag | Meaning |
|---|---|
| `--disable-shared` | Link Tcl and Tk statically |
| `--enable-zipfs` | Enable the zip virtual filesystem the single-file build relies on |
| `--enable-aqua` | Tk: use the native macOS windowing system instead of X11 |
| `--enable-64bit` | Build 64-bit; needed explicitly for the x86_64 cross build |
| `--prefix` | One directory per OS and architecture under `~/opt/tcl/9.1/` |
| `-mmacosx-version-min` | Oldest macOS the binaries will run on |

## tcllib and tklib

Both are pure Tcl, so there is nothing architecture-specific about them: install
each once. From each source directory:

```sh
# tcllib
./configure --prefix=$HOME/opt/tcllib/2.0
make -j$(sysctl -n hw.ncpu) install

# tklib
./configure --prefix=$HOME/opt/tklib/0.9
make -j$(sysctl -n hw.ncpu) install
```

They install into `~/opt/tcllib/2.0/lib/tcllib2.0` and
`~/opt/tklib/0.9/lib/tklib0.9`, the layout described in [Setup](setup.md).

> Use `$HOME` in `--prefix`, not `~`. zsh (the default macOS shell) does not
> expand `~` inside `--prefix=~/...`, so you would get a literal `~` directory.

## Not covered yet

- Windows x86_64
