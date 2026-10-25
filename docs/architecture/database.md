# Database

How Inventory uses SQLite: connection, settings and how to run queries.

For the Tcl interface itself (commands, binding, pitfalls) see [sqlite3](../tcl-notes/tcl/sqlite3.md).

## Connection

One connection, opened at startup as the global command `db` and closed when the
window closes. The file location is per OS (see [Running](../getting-started/running.md#where-the-data-lives)).

## Settings

Applied right after opening, in the startup code:

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
    INSERT INTO suppliers (name, created_at)
    VALUES (:name, :now)
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

## Handling constraint errors

The database is the last line of defense: uniqueness and "not empty" rules are
declared as constraints in the schema (name the `CHECK` ones, see
[Migrations](migrations.md#rules-that-follow-from-this)), and the UI does not
repeat them. When a write breaks one, SQLite raises an error whose text says
which constraint failed. Catch it with `try` (see [Error handling](../tcl-notes/tcl/error-handling.md)), map it to a translated message
(see [Internationalization](i18n.md)), show it with [tk_messageBox](../tcl-notes/tk/tk-messagebox.md) and re-raise anything you do not recognize:

```tcl
try {
    db eval {INSERT INTO suppliers (name) VALUES (:name)}
} on error {msg opts} {
    if {[regexp {^UNIQUE constraint failed: suppliers\.(\w+)} $msg -> column]} {
        set key suppliers.duplicate.$column
    } elseif {[regexp {^CHECK constraint failed: suppliers_(\w+)_not_empty} $msg -> column]} {
        set key suppliers.empty.$column
    } else {
        return -options $opts $msg
    }
    tk_messageBox -type ok -icon error -title [mc common.error] -message [mc $key]
    return
}
```
