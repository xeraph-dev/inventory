# ttk::combobox

A text field with a drop-down list of values. It is a `ttk::entry` plus a list the user can open.

## What it is and when to use it

Use it to pick one value from a short list (a category, a unit, a status). In `readonly` mode the user can only choose from the list; in `normal` mode the user can also type any text. For a long list that needs searching, or for several selections at once, use another widget.

## Minimal example

```tcl
package require Tk

set categories [list Pens Paper "Ink cartridges" Notebooks]

ttk::label .l -text "Category:"
ttk::combobox .cb -values $categories -state readonly -textvariable ::category
ttk::button .b -text "Show" -command {puts "category = '$::category' (index [.cb current])"}

bind .cb <<ComboboxSelected>> {puts "selected: [%W get]"}

.cb current 0
grid .l .cb .b -padx 4 -pady 8
```

## Concepts

- **It holds text, not keys.** The value of the combobox is the text shown. The list is just a list of strings: there is no hidden id behind each one.
- **`-values`** is a Tcl list with the choices, in display order.
- **`current`** is the index in `-values` of the text now shown, or `-1` if the text is not in the list (empty, typed by the user or set from code).
- **`<<ComboboxSelected>>`** is the virtual event generated when the user chooses an item from the list.
- **It is also an entry.** The entry commands and options work on it (`get`, `insert`, `delete`, `-textvariable`, `-validate`, `-width`, ...); see [ttk::entry](ttk-entry.md).

## Commands you will use

| Command | What it does |
|---|---|
| `$cb get` | Returns the text shown |
| `$cb set $text` | Sets the text |
| `$cb current` | Index of the shown text in `-values`, or `-1` |
| `$cb current $index` | Shows the value at that index |
| `$cb configure -values $list` | Replaces the list |
| `$cb selection clear` | Removes the highlight from the text |
| `$cb state $flags` / `$cb instate $flags` | Sets or tests state flags (`disabled`, `readonly`, ...) |

Options: `-values`, `-state` (`normal`, `readonly`, `disabled`), `-textvariable`, `-width` (characters, default 20), `-height` (maximum rows of the list before it scrolls, default 10), `-postcommand` (script run just before the list opens), `-justify`.

## Choosing by id

Since the combobox only holds text, keep the ids in a list in the same order as `-values` and use `current` as the link between them:

```tcl
set ids   {101 102 103}
set names {Pens Paper Ink}

ttk::combobox .cb -values $names -state readonly
pack .cb

proc selected-id {cb ids} {
    set i [$cb current]
    if {$i < 0} {return ""}
    lindex $ids $i
}

.cb current 1
puts [selected-id .cb $ids]   ;# 102
```

## Pitfalls

**`current` is `-1` when nothing from the list is shown.** A new combobox is empty, so it is `-1` until the user chooses something or you call `current 0`. Always check it before using it as an index.

**Matching against the list is exact and case sensitive.** After `set blue`, `current` finds `blue` but not `Blue`. If two items have the same text, `current` returns the first one, so items that map to different ids need different texts.

**`current` with an index outside the list raises an error** (`Index 9 out of range`).

**`<<ComboboxSelected>>` only means "the user chose an item".** `set` and `current $index` change the text without generating it, so code that must react to both has to be called from both places. In the handler, read the value with `$cb get` or `$cb current`.

**`readonly` only restricts the user.** `set` and the `-textvariable` accept any text, and `current` is then `-1`. A readonly combobox can show a value that is not in its list.

**Changing `-values` does not change the text shown.** The old text stays, and `current` becomes `-1` if it is no longer in the list. Reset it with `current 0` or `set ""`.

**Build `-values` with `list`.** `-values "Red pen Blue pen"` is split on spaces into four items. Use `-values [list "Red pen" "Blue pen"]`, or pass a variable that already holds a proper list.

**A `normal` combobox accepts any text and does not filter or autocomplete.** If the user must pick from the list, use `readonly`. If free text is allowed, check the text yourself; see [ttk::entry](ttk-entry.md) for validation.

**The list can be filled when it opens.** `-postcommand` runs right before the list is shown and may configure `-values`, which is the way to show data that changes (for example, rows read from a database) without refreshing the combobox by hand:

```tcl
proc refresh-values {cb} {
    $cb configure -values [list-current-options]
}

ttk::combobox .cb -state readonly -postcommand [list refresh-values .cb]
```

**The width is fixed.** `-width` counts characters (20 by default) and does not adapt to the longest value. A long value is cut in the field; set `-width` to fit the longest one.

**The chosen text may stay highlighted** after a selection in a readonly combobox, depending on the platform. Clearing it in the handler is harmless:

```tcl
bind .cb <<ComboboxSelected>> {%W selection clear}
```

## Official documentation

- [ttk::combobox](https://www.tcl-lang.org/man/tcl/TkCmd/ttk_combobox.htm)
