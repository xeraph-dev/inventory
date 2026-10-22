# Setup

What you need installed, and how the project expects its dependencies to be laid out.

## Requirements

| Component | Version | Why |
|---|---|---|
| Tcl/Tk | 9.1 | The app uses Tcl 9 features (`const`, `file home`, `file tempdir`, `zipfs`) |
| sqlite3 (Tcl package) | 3.53.4 | Database access |
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

For day-to-day development you only need the build that matches your own
machine. The other platform folders are only needed to build distributables
(see [Building](building.md)).

## Project layout

```
.
├── main.tcl         # Entry point
├── build.tcl        # Builds the distributable executables
├── src/             # Application code (sourced recursively at startup)
├── migrations/      # Database migrations (sourced recursively at startup)
├── msgs/            # Translation catalogs (*.msg)
├── res/             # Resources (app-icon.png)
├── lib/             # Third-party packages (see below)
└── dist/            # Build output (git-ignored)
```

### The `lib/` directory

`main.tcl` adds these directories to `auto_path`:

```
lib/
lib/tcllib/
lib/tklib/
```

So packages must be reachable from there:

```
lib/
├── sqlite3.53.4/    # the sqlite3 Tcl package
├── tcllib/
│   └── snit/
└── tklib/
```

The build copies the same structure into the executable, so development
and the packaged app resolve packages the same way.

Next: [Running the app](running.md).
