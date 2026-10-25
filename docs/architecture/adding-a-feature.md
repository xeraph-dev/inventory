# Adding a feature

The steps to add a new section to the app, from the database to the screen.

Use an existing section as a reference: copy its pattern.

## Checklist

| # | Step | Details |
|---|---|---|
| 1 | Create the table | [Migrations](migrations.md) |
| 2 | Create the panel and its parts (table, form) | [UI](ui.md) |
| 3 | Connect the parts and keep them in sync | [Communication](communication.md) |
| 4 | Add the tab | [UI](ui.md#adding-a-tab) |
| 5 | Add the strings | [Internationalization](i18n.md) |

Files are sourced automatically, so nothing needs to be registered besides the tab.

## Order of work

1. **Migration first.** Run the app once so it is applied, and check the table in the database.
2. **Panel with queries.** Use `db` with bound variables and transactions, and translate constraint errors into messages (see [Database](database.md)).
3. **Wiring.** Events between the table and the form, and a revision counter for the new table (see [Communication](communication.md)).
4. **Tab and strings.** Wire the panel into the notebook and add its title, and every other new text, to every catalog in `msgs/`.

## Check before you commit

- The app starts with a clean data directory (all migrations run from scratch).
- The app starts with an existing database (only the new migration runs).
- Every new key exists in every catalog.
- Saving or deleting in one place updates every table that shows that data.
