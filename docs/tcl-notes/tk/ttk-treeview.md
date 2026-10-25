# ttk::treeview

A treeview shows rows of data, either as a flat table with column headings or as a hierarchy. This note covers the flat table, which is what lists of records need.

## What it is and when to use it

`ttk::treeview` is Tk's table widget. Despite the name, it is the usual choice for a plain list of records: hide the tree column, define data columns, and insert one item per row. It does not scroll by itself (see [Scrolling](#scrolling)).

## Minimal example

A table of two columns:

```tcl
package require Tk

proc on-select {tv} {
    puts "selected id: [$tv selection]"
}

ttk::treeview .tv -columns {code name} -show headings -selectmode browse
pack .tv -fill both -expand yes

.tv heading code -text Code
.tv heading name -text Name
.tv column code -minwidth 80 -width 80
.tv column name -width 220

foreach {id code name} {1 A-100 "Red pen" 2 A-200 "Blue pen" 3 B-300 "Paper A4"} {
    .tv insert {} end -id $id -values [list $code $name]
}

bind .tv <<TreeviewSelect>> [list on-select .tv]
```

## Concepts

- **Columns.** `-columns` names the data columns. There is also a built-in column called `#0` that holds the tree (the expand arrows and the item's `-text`). With `-show headings` that column is hidden, which gives a plain table.
- **Items.** Every row is an item with an ID. `insert parent index` creates one: use `{}` as the parent for a flat list and `end` as the index. Pass `-id` to choose the ID yourself, or Tk generates one.
- **Values.** `-values` is a list with one element per data column, in column order.
- **Selection and focus.** The selected items and the focused item (the one with the focus ring) are two separate things.

## Commands you will use

| Command | What it does |
|---|---|
| `$tv insert {} end -id $id -values $list` | Adds a row |
| `$tv delete $items` | Removes the given items |
| `$tv children {}` | Lists the top-level item IDs, in display order |
| `$tv selection` | Returns the selected item IDs |
| `$tv selection set $id` | Selects an item; `selection set {}` clears the selection |
| `$tv focus ?$id?` | Returns or sets the focused item; `focus {}` clears it |
| `$tv heading $col -text $text` | Sets the heading text |
| `$tv column $col -minwidth N -width N` | Sets the minimum and the initial width of a column |

To clear the table: `$tv delete [$tv children {}]`. It also works when the table is already empty.

## Scrolling

A treeview shows only as many rows as fit; to scroll it, connect a `ttk::scrollbar` to it. Each one reports to the other, so both options are needed:

```tcl
package require Tk

ttk::frame .f
pack .f -fill both -expand yes

ttk::treeview .f.tv -columns {code name} -show headings -selectmode browse \
    -yscrollcommand [list .f.sb set]
ttk::scrollbar .f.sb -orient vertical -command [list .f.tv yview]

pack .f.tv -side left -fill both -expand yes
pack .f.sb -side right -fill y
```

Create the treeview and the scrollbar as siblings in the same container. For how the two callbacks work and their pitfalls, see [ttk::scrollbar](ttk-scrollbar.md).

## Pitfalls

**Always build `-values` with `list`.** `-values "$code $name"` is split on spaces, so a name like `Red pen` becomes two values and lands in the wrong cell. Use `-values [list $code $name]`.

**Use the database key as the item `-id`.** Then `[$tv selection]` gives you the key directly and you never need a lookup table. IDs must be unique within the treeview.

**`<<TreeviewSelect>>` (a [virtual event](events.md)) fires on programmatic changes too**, not only on clicks, and it fires when the selected item is deleted. In that case `$tv selection` is empty inside the handler, so always handle the empty case. If your handler can end up selecting a row itself, make it harmless to run twice for the same row.

**Clearing the selection does not clear the focus.** After `selection set {}` the last item keeps the focus ring; also call `focus {}` to remove it.

**The default `-selectmode` is `extended`** (multiple selection). Use `browse` for a single selected row.

**Refreshing the table clears the selection.** Deleting every item and inserting them again deselects the row, and fires `<<TreeviewSelect>>` once for the deletion.

**`-width` is only the starting width.** `-minwidth` is the smallest width the user can drag a column to.

## Official documentation

- [ttk::treeview](https://www.tcl-lang.org/man/tcl/TkCmd/ttk_treeview.htm)
