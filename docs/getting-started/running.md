# Running the app

How to launch Inventory in development and what happens at startup.

## Launch

From the project root, with the Tcl 9.1 `wish` for your platform:

```sh
wish9.1 main.tcl
```

`main.tcl` locates its own directory through `[info script]`, so the
working directory does not matter for the app itself.

## What happens at startup

`main.tcl` runs these steps in order:

1. Defines `APP_DIR` and `APP_NAME` as constants.
2. Extends `auto_path` with `lib/`, `lib/tcllib` and `lib/tklib`.
3. Loads the packages `snit`, `sqlite3` and `msgcat`.
4. Sources every `.tcl` file under `src/` and `migrations/`, recursively.
5. Creates the data directory and opens the SQLite database as the command `db`.
6. Applies pragmas: foreign keys on, WAL journal mode, `synchronous = FULL`.
7. Loads the translation catalogs from `msgs/`.
8. Runs pending migrations.
9. Sets the window title and icon, packs the `app` widget and fixes the minimum window size.
10. Registers a `WM_DELETE_WINDOW` handler that closes the database before destroying the window.

Because files are sourced automatically, **adding a new `.tcl` file under
`src/` or `migrations/` is enough for it to be loaded**. No registration is needed.

## Where the data lives

The database is created on first run:

| OS | Path |
|---|---|
| macOS | `~/Library/Application Support/inventory/inventory.db` |
| Windows | `%APPDATA%\inventory\inventory.db` |

SQLite in WAL mode also creates `inventory.db-wal` and `inventory.db-shm`
next to it. This is normal.

To start from a clean state during development, close the app and delete the
`inventory` data directory.

## Common problems

- **`can't find package sqlite3` or `snit`**: the `lib/` directory is not laid out as described in [Setup](setup.md).
- **`invalid command name "const"`** (or `file home`): you are running Tcl 8.x. Use Tcl 9.1.
- **`unknown platform`** from `get_data_dir`: only macOS and Windows are supported.

Next: [Building](building.md).
