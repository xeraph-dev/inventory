# Migrations

How the database schema evolves, and how to add a migration.

## Adding a migration

Create `migrations/NNN-name.tcl`, where `NNN` is the next number, and register a script with the same number:

```tcl
migrations register 7 {
    db eval {
        CREATE TABLE IF NOT EXISTS suppliers (
            id      INTEGER PRIMARY KEY,
            name    TEXT    UNIQUE  NOT NULL,
            notes   TEXT            NOT NULL DEFAULT '',

            CONSTRAINT suppliers_name_not_empty CHECK (trim(name) <> '')
        ) STRICT
    }
}
```

That is all: the file is sourced automatically (see [Overview](overview.md#loading-model)) and
pending migrations run on the next startup.

## How it behaves

- Applied versions are recorded in the `schema_migrations` table. On startup, only migrations **newer than the highest recorded version** run, in numeric order.
- Each migration runs in a transaction together with its `schema_migrations` row. If it fails, nothing is applied and the error stops startup.

## Rules that follow from this

- **Always use the next number.** A migration numbered below the current version is skipped silently on databases that are already past it.
- **Never edit a migration that has been applied.** It will not run again, so databases that already applied it keep the old schema, and new databases get a different one. Fix it with a new migration.
- **Keep migrations small and independent** of application code: they must keep working years later, when the code has changed.
- SQLite can run DDL in a transaction, but its `ALTER TABLE` is limited. Changing or dropping a column often means creating a new table, copying the data and renaming. Do it inside a single migration.
- Tables use `STRICT` (see [Database](database.md)).
- **Name the `CHECK` constraints** (`<table>_<column>_<rule>`): the error text then says which rule failed, and the UI can show the right message (see [Handling constraint errors](database.md#handling-constraint-errors)).

## Starting from scratch in development

Delete the data directory (see [Running](../getting-started/running.md)). All
migrations run again on the next startup.
