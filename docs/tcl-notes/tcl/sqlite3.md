# sqlite3

The Tcl interface to SQLite. It is a package: `package require sqlite3` and the `sqlite3` command creates a database connection that is itself a command.

## What it is and when to use it

Use it for any data that must survive between runs and be queried: records, history, settings. The connection is an object: `sqlite3 db file` creates a command named `db`, and everything is done with subcommands (`db eval`, `db transaction`, ...).

## Minimal example

Runs as is with `tclsh` or `wish`; it creates `example.db` in the current directory:

```tcl
package require sqlite3

sqlite3 db example.db
db eval {PRAGMA foreign_keys = ON}

db eval {
    CREATE TABLE IF NOT EXISTS items (
        id    INTEGER PRIMARY KEY,
        code  TEXT UNIQUE NOT NULL,
        name  TEXT NOT NULL
    ) STRICT
}
db eval {DELETE FROM items}

proc add-item {code name} {
    db eval {INSERT INTO items (code, name) VALUES (:code, :name)}
    return [db last_insert_rowid]
}

add-item A-100 "Red pen"
add-item A-200 "Blue pen"

# All values as one flat list
puts [db eval {SELECT code, name FROM items ORDER BY code}]

# Row by row: the columns become variables
db eval {SELECT id, code, name FROM items ORDER BY code} {
    puts "$id: $code / $name"
}

# One value
puts [db onecolumn {SELECT count(*) FROM items}]

db close
```

## Concepts

- **The connection is a command.** `sqlite3 db path` creates it (and the file, if it does not exist); `db close` ends it.
- **Bound variables.** In the SQL, `:name` is replaced by the value of the Tcl variable `name`, taken from the scope that calls `db eval`, inside a proc too. The value is passed to SQLite as a parameter, not pasted into the text, so it needs no quoting and cannot inject SQL. Write the SQL in **braces** so Tcl does not substitute the variables first.
- **Tcl has no types, SQLite does.** The binding looks at the value's current representation: a number that came out of `expr` or `incr` is bound as an integer or a real, anything else as text. Tables created with `STRICT` make SQLite check the column types and convert or reject the value, so the result does not depend on how Tcl happened to represent it.

## Commands you will use

| Command | What it does |
|---|---|
| `db eval $sql` | Runs the statements and returns all result values as one flat list |
| `db eval $sql $script` | Runs `$script` once per row, with the columns as variables named after them |
| `db onecolumn $sql` | Returns the first column of the first row, or an empty string if there is none |
| `db transaction $script` | Runs `$script` inside a transaction (see below) |
| `db last_insert_rowid` | The `rowid` of the last inserted row |
| `db close` | Closes the connection |

### Transactions

```tcl
db transaction {
    db eval {UPDATE items SET name = :name WHERE id = :id}
    db eval {INSERT INTO log (item_id) VALUES (:id)}
}
```

If the script raises an error, everything is rolled back and the error is raised again.

### Loading one row

With an empty script, `db eval` is a compact way to load a single row into variables:

```tcl
db eval {SELECT code, name FROM items WHERE id = :id} {}
puts "$code / $name"
```

## Pitfalls

**Write SQL in braces, never in quotes.** With `"... WHERE id = $id"` Tcl substitutes the value into the text before SQLite sees it, which brings back quoting problems and SQL injection. With braces, SQLite receives `:id` and binds the variable.

**Only values can be bound, not names.** A table or column name cannot be a variable: `SELECT * FROM :table` is a syntax error.

**NULL and the empty string look the same when reading.** A NULL is returned as `""`, so `db onecolumn` cannot tell a NULL from an empty text or from "no row". To test for NULL, do it in SQL (`WHERE notes IS NULL`); to test for a row, ask for `count(*)`.

**An unset variable is bound as NULL, an empty variable as empty text.** `set notes ""` inserts an empty string. A variable that does not exist (typo, wrong scope) is silently bound as NULL instead of raising an error. If a column that should have a value is NULL, check the variable name.

**With the script form, columns become variables.** `db eval {SELECT id, name FROM items} {...}` sets `id` and `name` in the calling scope and overwrites any variable that already had those names.

**A query with no rows leaves the variables untouched.** When loading one row with an empty script, if nothing matches, `code` and `name` keep whatever they had before (or stay unset). Check that the row exists, or set the variables to a known value first.

**The flat list needs to be consumed in groups.** `db eval {SELECT code, name FROM items}` returns `A-100 {Red pen} A-200 ...`. Read it with `foreach {code name} [db eval ...]`, and use as many variables as there are columns.

**`onecolumn` hides a missing row.** It returns an empty string both for no row and for an empty value.

**Settings that belong to the connection must be set every time you open it.** For example `PRAGMA foreign_keys = ON` is not stored in the file: without it, foreign keys are not enforced.

**Errors are Tcl errors with SQLite's message.** Catch them with `try ... on error` (or `catch`; see [Error handling](error-handling.md)) and look at the text:

```tcl
try {
    db eval {INSERT INTO items (code, name) VALUES (:code, :name)}
} on error {msg opts} {
    if {[regexp {^UNIQUE constraint failed: items\.(\w+)} $msg -> column]} {
        puts "duplicate $column"
    } else {
        return -options $opts $msg
    }
}
```

| Message | Cause |
|---|---|
| `UNIQUE constraint failed: items.code` | A value that must be unique already exists |
| `NOT NULL constraint failed: items.name` | The variable was unset or the column was left out |
| `CHECK constraint failed: items_name_not_empty` | A `CHECK` rule was broken; the text is the constraint's name if it has one, or its expression |
| `cannot store TEXT value in INTEGER column items.id` | `STRICT` table and a value that cannot be converted to the column type |
| `no such table: items` | The table does not exist yet, or the connection points to another file |
| `can't find package sqlite3` | The Tcl in use does not include the package |

## Official documentation

- [The Tcl interface to SQLite](https://www.sqlite.org/tclsqlite.html)
- [SQLite STRICT tables](https://www.sqlite.org/stricttables.html)
