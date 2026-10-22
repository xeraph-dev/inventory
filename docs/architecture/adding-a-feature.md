# Adding a feature

The steps to add a new section to the app, from the database to the screen.

The products section is the reference implementation: copy its pattern.

## Checklist

| # | Step | Reference | Details |
|---|---|---|---|
| 1 | Create the table | `migrations/001-products.tcl` | [Migrations](migrations.md) |
| 2 | Create the panel | `src/products/products-panel.tcl` | [UI](ui.md) |
| 3 | Add the tab | `src/app.tcl` | [UI](ui.md#adding-a-tab) |
| 4 | Add the strings | `msgs/es.msg` | [Internationalization](i18n.md) |

Files are sourced automatically, so nothing needs to be registered besides the tab.

## Order of work

1. **Migration first.** Run the app once so it is applied, and check the table in the database.
2. **Panel with queries.** Use `db` with bound variables and transactions (see [Database](database.md)).
3. **Tab and strings.** Wire the panel into the notebook and add its title to every catalog in `msgs/`.

## Check before you commit

- The app starts with a clean data directory (all migrations run from scratch).
- The app starts with an existing database (only the new migration runs).
- Every new key exists in every catalog.
