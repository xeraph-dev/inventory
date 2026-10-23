# Architecture overview

How the project is put together: what each directory is for, what is global, and why the startup order matters.

## Directories

| Directory | Role |
|---|---|
| `src/` | Application code: widgets, helpers, the migration engine. One subdirectory per area (`src/products/`). |
| `migrations/` | One file per database migration. See [Migrations](migrations.md). |
| `msgs/` | Translation catalogs. See [Internationalization](i18n.md). |
| `res/` | Static resources (the app icon). |
| `lib/` | Vendored third-party packages, if any (see [Setup](../getting-started/setup.md)). |

## What is global

| Name | What it is |
|---|---|
| `APP_DIR`, `APP_NAME`, `DEFAULT_LOCALE`, `DATA_DIR` | Constants defined with `const` in `main.tcl` |
| `db` | The single SQLite connection. See [Database](database.md). |
| `mc`, `mcset`, `mcload`, ... | All of `msgcat`, imported into the global namespace |

`APP_DIR` comes from `[info script]`, so the same code runs from the source
tree and from inside the zipfs bundle.

## Loading model

Everything under `src/` and then `migrations/` is sourced automatically. Within
each directory, the `.tcl` files are sourced first (alphabetical order), then the
subdirectories (alphabetical, recursively).

Consequences:

- **A file cannot rely on another file's definitions while it is being sourced**, only once the app is running. Defining `snit::widget`s and procs is fine; calling them at source time is not.
- **`src/` is sourced before `migrations/` on purpose.** Migration files call `migrations register`, which is defined in `src/migrations.tcl`.
- Migration files must only *register* a script. They must not touch `db` at source time: the connection does not exist yet.

## Startup order

The order in `main.tcl` is deliberate:

1. Code is sourced, then the database is opened.
2. Migrations run, then message catalogs are loaded, **then** the UI is created.

So the UI can always assume that the schema is up to date and that `mc`
already has its catalog.

The window's minimum size is its requested size at startup. A tab that needs
more room raises the minimum for the whole window.

Closing the window closes `db` first, then destroys the window.

## Where to go next

- Add a table or change the schema: [Migrations](migrations.md)
- Add or translate text: [Internationalization](i18n.md)
- Add a screen: [UI](ui.md)
- All of the above together: [Adding a feature](adding-a-feature.md)
