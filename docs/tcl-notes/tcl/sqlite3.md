# sqlite3

The Tcl interface to SQLite. It is a package: `package require sqlite3` and the `sqlite3` command creates a database connection that is itself a command.

## What it is and when to use it

Use it for any data that must survive between runs and be queried: records, history, settings. The connection is an object: `sqlite3 db file` creates a command named `db`, and everything is done with subcommands (`db eval`, `db transaction`, ...).

## Minimal example

Runs as is with `tclsh` or `wish`, using an in-memory database:

```tcl
package require sqlite3

sqlite3 db :memory:

db eval {
    CREATE TABLE items (
        id    INTEGER PRIMARY KEY,
        code  TEXT UNIQUE NOT NULL,
        name  TEXT NOT NULL,
        notes TEXT
    ) STRICT
}

proc add-item {code name {notes ""}} {
    db eval {INSERT INTO items (code, name, notes) VALUES (:code, :name, :notes)}
    return [db last_insert_rowid]
}

add-item A-100 "Red pen"
add-item A-200 "Blue pen" "Box of 12"

# All rows as one flat list
puts [db eval {SELECT code, name FROM items ORDER BY code}]

# Row by row, into an array
db eval {SELECT id, code, name FROM items ORDER BY code} row {
    puts "$row(id): $row(code) / $row(name)"
}

# One value, and an existence check
puts [db onecolumn {SELECT count(*) FROM items}]
set code A-100
puts [db exists {SELECT 1 FROM items WHERE code = :code}]

db close
```

## Concepts

- **The connection is a command.** `sqlite3 db path` creates it; `db close` ends it. Pass `:memory:` as the path for a throwaway database. The file is created if it does not exist (use `-create false` to forbid it, `-readonly true` to open it read only).
- **Bound variables.** In the SQL, `:name` (or `$name`) is replaced by the value of the Tcl variable `name`, taken from the scope that calls `db eval`, inside a proc too. The value is passed to SQLite as a parameter, not pasted into the text, so it needs no quoting and cannot inject SQL. Write the SQL in **braces** so Tcl does not substitute the variables first.
- **Tcl has no types, SQLite does.** The binding looks at the value's current representation: a number that came out of `expr` or `incr` is bound as an integer or a real, anything else as text. Tables created with `STRICT` make SQLite check the column types and convert or reject the value, so the result does not depend on how Tcl happened to represent it.

## Commands you will use

| Command | What it does |
|---|---|
| `db eval $sql` | Runs the statements and returns all result values as one flat list |
| `db eval $sql $array $script` | Runs `$script` once per row, with the columns in `$array(column)`; `$array(*)` holds the column names |
| `db eval $sql $script` | Same, but the columns become variables named after them (see the pitfall below) |
| `db onecolumn $sql` | Returns the first column of the first row, or an empty string if there is none |
| `db exists $sql` | Returns 1 if the query returns at least one row, 0 if not |
| `db transaction ?mode? $script` | Runs `$script` inside a transaction (see below) |
| `db changes` | Number of rows changed by the last `INSERT`, `UPDATE` or `DELETE` |
| `db last_insert_rowid` | The `rowid` of the last inserted row |
| `db nullvalue ?$string?` | Reads or sets what a NULL is returned as (empty string by default) |
| `db timeout $ms` | How long to wait if the database is locked by another connection |
| `db backup ?$dbname? $file` | Copies the database into a file |
| `db version` | SQLite version |
| `db close` | Closes the connection |

### Transactions

```tcl
db transaction {
    db eval {UPDATE items SET notes = :notes WHERE id = :id}
    db eval {INSERT INTO log (item_id) VALUES (:id)}
}
```

If the script raises an error, everything is rolled back and the error is raised again. A `transaction` inside another one becomes a savepoint, so it can be nested. `mode` is `deferred` (the default), `immediate` or `exclusive`.

## Pitfalls

**Write SQL in braces, never in quotes.** With `"... WHERE id = $id"` Tcl substitutes the value into the text before SQLite sees it, which brings back quoting problems and SQL injection. With braces, SQLite receives `$id` and binds the variable.

**Only values can be bound, not names.** A table or column name cannot be a variable (`SELECT * FROM :table` is a syntax error). The same goes for a list in `IN (...)`: one variable is one value. For a list, generate one placeholder per element and set one variable per element:

```tcl
set ids {3 7 9}
set names {}
set i 0
foreach id $ids {
    set v$i $id
    lappend names :v$i
    incr i
}
db eval "SELECT name FROM items WHERE id IN ([join $names ,])"
```

Here the double quotes are safe because only the placeholder names are interpolated, never the values.

**NULL and the empty string look the same when reading.** By default a NULL is returned as `""`, so `db onecolumn` cannot tell a NULL from an empty text or from "no row". To test for NULL, do it in SQL (`WHERE notes IS NULL`), use `db exists` to ask whether a row exists, or set a recognizable `db nullvalue` while reading.

**An unset variable is bound as NULL, an empty variable as empty text.** `set notes ""` inserts an empty string. A variable that does not exist (typo, wrong scope) is silently bound as NULL instead of raising an error. If a column that should have a value is NULL, check the variable name.

**With the script form, columns become variables.** `db eval {SELECT id, name FROM items} {...}` sets `id` and `name` in the calling scope and overwrites any variable that already had those names. Use the array form (`db eval $sql row {...}`) to avoid it.

**The flat list needs to be consumed in groups.** `db eval {SELECT code, name FROM items}` returns `A-100 {Red pen} A-200 ...`. Read it with `foreach {code name} [db eval ...]`, and use as many variables as there are columns.

**`onecolumn` hides a missing row.** It returns an empty string both for no row and for an empty value. Use `db exists` when the difference matters.

**Real numbers are binary floats.** `0.1 + 0.2` comes back as `0.30000000000000004`. For amounts of money, store the smallest unit (cents) in an `INTEGER` column and format it when showing it.

**Settings that belong to the connection must be set every time you open it.** For example `PRAGMA foreign_keys = ON` is not stored in the file: without it, foreign keys are not enforced.

**Errors are Tcl errors with SQLite's message.** Catch them with `catch` or `try` and look at the text:

| Message | Cause |
|---|---|
| `UNIQUE constraint failed: items.code` | A value that must be unique already exists |
| `NOT NULL constraint failed: items.name` | The variable was unset or the column was left out |
| `cannot store TEXT value in INTEGER column items.id` | `STRICT` table and a value that cannot be converted to the column type |
| `no such table: items` | The table does not exist yet, or the connection points to another file |
| `database is locked` | Another connection is writing; see `db timeout` |
| `can't find package sqlite3` | The Tcl in use does not include the package |

## Official documentation

- [The Tcl interface to SQLite](https://www.sqlite.org/tclsqlite.html)
- [SQLite STRICT tables](https://www.sqlite.org/stricttables.html)
