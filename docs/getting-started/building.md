# Building

How to produce single-file executables for each target platform.

## Run a build

From the project root, with a Tcl 9.1 interpreter:

```sh
tclsh9.1 build.tcl
```

Output goes to `dist/` (git-ignored):

| Target | Output file |
|---|---|
| macOS arm64 | `dist/inventory-osx-arm64` |
| macOS x86_64 | `dist/inventory-osx-x86_64` |
| Windows x86_64 | `dist/inventory-x86_64.exe` |

The script builds **all** targets in one run, so it needs the full `~/opt`
layout described in [Setup](setup.md). The static Tcl/Tk it appends the app to
is built as described in [Tcl and Tk from source](tcl-from-source.md).

The output files are bare executables. Packaging them as a proper macOS `.app`
or a Windows installer is not done yet.

## How it works

Tcl 9 includes **zipfs** (see [zipfs](../tcl-notes/tcl/zipfs.md)), a virtual filesystem backed by a zip archive. A
Tcl/Tk executable with a zip archive appended to it can run code from inside
that archive. `build.tcl` assembles the app, its packages and the Tcl/Tk
libraries into an archive and appends it to each platform's `wish`.

## Configuration

Everything configurable is at the top of `build.tcl`:

| Constant | Meaning |
|---|---|
| `TCL`, `TCLLIB`, `TKLIB` | Install locations |
| `PKGS` | Binary packages copied from the Tcl `lib/` directory (`sqlite3`, with its version) |
| `TCLLIB_PKGS` | tcllib packages to bundle (`snit`) |
| `TKLIB_PKGS` | tklib packages to bundle |
| `APP_ITEMS` | Files and directories of the app to bundle |

## Adding a dependency

- **A tcllib package**: add its name to `TCLLIB_PKGS` (for example `{snit struct}`), and make it available under `lib/tcllib/` for development.
- **A tklib package**: add it to `TKLIB_PKGS`, and make it available under `lib/tklib/` for development.
- **A binary package** (like sqlite3): add it to `PKGS`. It must exist under each platform's `lib/` directory.

See [Setup](setup.md#the-lib-directory) for how `lib/` is used in development.
