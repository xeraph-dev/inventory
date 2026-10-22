# Setup

What you need installed, and how the project expects its dependencies to be laid out.

## Requirements

| Component | Version | Why |
|---|---|---|
| Tcl/Tk | 9.1 | The app uses Tcl 9 features (`const`, `file home`, `file tempdir`, `zipfs`) |
| sqlite3 (Tcl package) | 3.53.4 | Database access; bundled in the Tcl source tarball |
| tcllib | 2.0 | Provides `snit` (the object system used for widgets) |
| tklib | 0.9 | Extra Tk widgets; currently none are used |

`msgcat` and `ttk` ship with Tcl/Tk itself.

> **Tcl 9 is required.** The code will not run on Tcl 8.6.

## Supported platforms

| OS | Architectures | Notes |
|---|---|---|
| macOS | arm64, x86_64 | Development and distribution |
| Windows | x86_64 | Distribution (uses a static `wish91s.exe`) |

## Installation layout used by the build

`build.tcl` expects everything under `~/opt`:

```
~/opt/
├── tcl/9.1/
│   ├── osx/arm64/    { bin/wish9.1, lib/sqlite3.53.4/ ... }
│   ├── osx/x86_64/   { bin/wish9.1, lib/sqlite3.53.4/ ... }
│   └── win/x86_64/   { bin/wish91s.exe, lib/sqlite3.53.4/ ... }
├── tcllib/2.0/lib/tcllib2.0/    # contains snit/, ...
└── tklib/0.9/lib/tklib0.9/
```

To build Tcl and Tk yourself, see [Tcl and Tk from source](tcl-from-source.md).

This layout is only needed to build distributables (see [Building](building.md)).

## Development

To run the app while developing you do not need `~/opt`: any Tcl/Tk **9.1**
installation works, as long as it provides `sqlite3` and `snit` (tcllib).
On macOS, `brew install tcl-tk` installs one. Check the version with
`info patchlevel` (see [Running](running.md)).

## Project layout

```
.
├── main.tcl         # Entry point
├── build.tcl        # Builds the distributable executables
├── src/             # Application code
├── migrations/      # Database migrations
├── msgs/            # Translation catalogs (*.msg)
├── res/             # Resources (app-icon.png)
├── lib/             # Third-party packages (see below)
└── dist/            # Build output (git-ignored)
```

### The `lib/` directory

Optional. Use it to vendor a third-party package that is not part of the
installed Tcl. `main.tcl` appends these directories to `auto_path`, after the
ones of the Tcl installation, so installed packages take precedence:

```
lib/
lib/tcllib/
lib/tklib/
```

The build bundles `sqlite3`, `snit` and any tklib packages into the same
structure inside the executable (see [Building](building.md)).
