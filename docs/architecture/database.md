# Database

How Inventory uses SQLite: connection, settings and how to run queries.

## Connection

One connection, opened at startup as the global command `db` and closed when the
window closes. The file location is per OS (see [Running](../getting-started/running.md#where-the-data-lives)).

## Settings

Applied right after opening, in `main.tcl`:

| Pragma | Value | Why |
|---|---|---|
| `foreign_keys` | `ON` | SQLite ignores foreign keys unless this is set on every connection |
| `journal_mode` | `WAL` | Readers do not block the writer; creates the `-wal` and `-shm` files |
| `synchronous` | `FULL` | Every commit is flushed to disk, so a committed transaction survives an abrupt power loss. Slower writes, in exchange for durability. |

## Tables are `STRICT`

Tables are created with `STRICT`, so SQLite enforces column types instead of
accepting anything. Allowed types are `INTEGER`, `REAL`, `TEXT`, `BLOB` and `ANY`.
There is no `BOOLEAN` or `DATE`: use `INTEGER` (0/1) and `INTEGER` (unix time) or `TEXT`.

The schema is defined by the files in `migrations/`, which are the source of
truth. See [Migrations](migrations.md).

## Running queries

Tcl variables are bound into the SQL with a `:` prefix, taken from the calling scope:

```tcl
set now [clock seconds]
db eval {
    INSERT INTO schema_migrations (version, applied_at)
    VALUES (:version, :now)
}
```

Always pass values this way and never build SQL by interpolating strings: bound
variables are safe against SQL injection and handle quoting for you.

Group several statements that must succeed or fail together in a transaction:

```tcl
db transaction {
    db eval {...}
    db eval {...}
}
```

If the body raises an error, the transaction is rolled back and the error is
re-raised.
