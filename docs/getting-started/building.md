# Building

How `build.tcl` produces single-file executables for each target platform.

## Run a build

From the project root, with a Tcl 9.1 interpreter:

```sh
tclsh9.1 build.tcl
```

Output goes to `build/` (git-ignored):

| Target | Output file |
|---|---|
| macOS arm64 | `build/inventory-osx-arm64` |
| macOS x86_64 | `build/inventory-osx-x86_64` |
| Windows x86_64 | `build/inventory-x86_64.exe` |

The script builds **all** targets in one run, so it needs the full `~/opt`
layout described in [Setup](setup.md).

## How it works

Tcl 9 includes **zipfs**, a virtual filesystem backed by a zip archive. A
Tcl/Tk executable with a zip archive appended to it can run code from inside
that archive. That is how the app ships as one file.

For each `{os arch exe}` triple, `build.tcl`:

1. Creates a temporary directory (`inventory-<os>-<arch>.vfs`) that will become the archive contents.
2. Mounts the target's `wish` executable with `zipfs mount` and copies `tcl_library` and `tk_library` out of it, since the app needs them inside its own archive.
3. Copies the application items: `lib`, `migrations`, `msgs`, `res`, `src`, `main.tcl` (the `APP_ITEMS` list).
4. Copies the packages for that target:
   - `sqlite3` from the platform's Tcl `lib/` directory, into `lib/`.
   - `snit` from tcllib, into `lib/tcllib/`.
   - tklib packages into `lib/tklib/`.
5. Calls `zipfs mkimg` to append the archive to the platform's `wish` executable, producing the final file.
6. Deletes the temporary directory.

### Configuration

Everything configurable is at the top of `build.tcl`:

| Constant | Meaning |
|---|---|
| `TCL`, `TCLLIB`, `TKLIB` | Install locations |
| `PKGS` | Packages copied from the Tcl `lib/` directory (`sqlite3.53.4`) |
| `TCLLIB_PKGS` | tcllib packages to bundle (`snit`) |
| `TKLIB_PKGS` | tklib packages to bundle (none yet) |
| `APP_ITEMS` | Files and directories of the app to bundle |

### Adding a dependency

- **A tcllib package**: add its name to `TCLLIB_PKGS` (for example `{snit struct}`), and make it available under `lib/tcllib/` for development.
- **A tklib package**: add it to `TKLIB_PKGS`.
- **A binary package** (like sqlite3): add it to `PKGS`. It must exist under each platform's `lib/` directory.
