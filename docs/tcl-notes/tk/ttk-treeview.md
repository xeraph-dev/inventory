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
.tv column code -width 80 -stretch no
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

## Commands you will use

| Command | What it does |
|---|---|
| `$tv insert {} end -id $id -values $list` | Adds a row |
| `$tv delete $items` | Removes the given items |
| `$tv children {}` | Lists the top-level item IDs, in display order |
| `$tv selection` | Returns the selected item IDs |
| `$tv selection set $id` | Selects an item |
| `$tv item $id -values` | Reads or sets all the values of a row |
| `$tv set $id $column` | Reads or sets one cell |
| `$tv heading $col -text T -command C` | Sets the heading text and its click handler |
| `$tv column $col -width N -stretch no` | Sets the width; `-stretch no` keeps it fixed when the window resizes |
| `$tv identify row $x $y` | Returns the item under a point, useful for double-click |

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

grid .f.tv -row 0 -column 0 -sticky nsew
grid .f.sb -row 0 -column 1 -sticky ns
grid columnconfigure .f 0 -weight 1
grid rowconfigure    .f 0 -weight 1
```

Create the treeview and the scrollbar as siblings in the same container, and give the treeview's row and column a grid weight, or it keeps its initial size instead of filling the window. For horizontal scrollbars and hiding the bar when it is not needed, see [ttk::scrollbar](ttk-scrollbar.md).

## Sorting

Treeview has no built-in sorting: you reorder the items yourself. `move` changes an item's position without recreating it, so selection and IDs are kept:

```tcl
proc sort-by {tv col {descending 0}} {
    set rows {}
    foreach item [$tv children {}] {lappend rows [list [$tv set $item $col] $item]}
    set dir [expr {$descending ? "-decreasing" : "-increasing"}]
    set i 0
    foreach row [lsort -dictionary $dir -index 0 $rows] {
        $tv move [lindex $row 1] {} $i
        incr i
    }
}

.tv heading name -command [list sort-by .tv name]
```

Cell values come back as strings, so choose the `lsort` mode that fits the column (`-dictionary`, `-integer`, `-real`).

## Pitfalls

**Always build `-values` with `list`.** `-values "$code $name"` is split on spaces, so a name like `Red pen` becomes two values and lands in the wrong cell. Use `-values [list $code $name]`.

**Use the database key as the item `-id`.** Then `[$tv selection]` gives you the key directly and you never need a lookup table. IDs must be unique within the treeview.

**`<<TreeviewSelect>>` fires on programmatic changes too**, not only on clicks, and it fires when the selected item is deleted. In that case `$tv selection` is empty inside the handler, so always handle the empty case.

**The default `-selectmode` is `extended`** (multiple selection). Use `browse` for a single selected row.

**`-height` sets only the initial number of visible rows.** After that the treeview's size depends on the geometry manager: it fills the window only if the container is configured to give it the space (`pack -fill both -expand yes`, or grid weights).

## Official documentation

- [ttk::treeview](https://www.tcl-lang.org/man/tcl/TkCmd/ttk_treeview.htm)
