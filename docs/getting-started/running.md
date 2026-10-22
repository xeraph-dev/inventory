# Running the app

How to launch Inventory in development.

## Launch

From any directory, with the `wish` of any installed Tcl/Tk 9.1 (on macOS,
`brew install tcl-tk` provides one; see [Setup](setup.md)):

```sh
wish9.1 main.tcl
```

Make sure it really is 9.1: run `wish9.1` and type `info patchlevel` in its console.

## Good to know

- Every `.tcl` file under `src/` and `migrations/` is sourced automatically, recursively and in alphabetical order. **Adding a file is enough for it to be loaded**; there is no registration step.
- Migrations run on every startup; only the pending ones are applied.

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

- **`can't find package sqlite3` or `snit`**: the Tcl you are using does not provide it (`snit` comes from tcllib). Install it, or vendor it under `lib/` as described in [Setup](setup.md).
- **`invalid command name "const"`** (or `file home`): you are running Tcl 8.x. Use Tcl 9.1.
- **`unknown platform`** from `get_data_dir`: only macOS and Windows are supported.
