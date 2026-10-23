# ttk::scrollbar

A bar that shows which part of a larger content is visible and lets the user move it. It holds no content: it is wired to another widget that does.

## What it is and when to use it

Use it with any widget that can scroll (`listbox`, `text`, `canvas`, `ttk::treeview`, ...). Those widgets never draw a scrollbar themselves; you create one and connect the two.

## Minimal example

A listbox with a vertical scrollbar:

```tcl
package require Tk

ttk::frame .f
pack .f -fill both -expand yes

listbox .f.lb -yscrollcommand [list .f.sb set]
ttk::scrollbar .f.sb -orient vertical -command [list .f.lb yview]

grid .f.lb -row 0 -column 0 -sticky nsew
grid .f.sb -row 0 -column 1 -sticky ns
grid columnconfigure .f 0 -weight 1
grid rowconfigure    .f 0 -weight 1

for {set i 1} {$i <= 100} {incr i} {.f.lb insert end "Item $i"}
```

## How the connection works

Two callbacks, one in each direction:

- **Widget to scrollbar.** Whenever the visible part changes, the widget calls its `-yscrollcommand` with two fractions between 0 and 1 (where the visible part starts and ends). `$sb set first last` stores them and redraws the thumb.
- **Scrollbar to widget.** When the user drags the thumb or clicks the arrows or the trough, the scrollbar calls its `-command` with extra arguments appended (`moveto 0.4`, `scroll 1 units`, `scroll 1 pages`). The widget's own `yview` method understands them.

That is why the wiring is always `-yscrollcommand [list $sb set]` on the widget and `-command [list $widget yview]` on the scrollbar.

For a horizontal scrollbar, change the names: `-orient horizontal`, `-xscrollcommand` on the widget, `xview` in the scrollbar's `-command`, and in the grid use `-row 1 -sticky ew`.

## Commands you will use

| Command | What it does |
|---|---|
| `$sb set $first $last` | Sets the thumb position (normally called by the widget, not by you) |
| `$sb get` | Returns the last `first last` pair |
| `$sb configure -command $cmd` | Changes the callback |

## Pitfalls

**Both directions are needed.** Without `-yscrollcommand` the thumb never moves or resizes; without `-command` dragging the thumb does nothing.

**Use `list` to build both callbacks.** `[list .f.sb set]` keeps the command as a proper Tcl list, whatever the widget path contains.

**The scrollbar is a sibling of the scrolled widget, not its child.** Create both in the same container so one `grid` arrangement controls them.

**The scrollbar does nothing visible without the grid weights.** Without `grid columnconfigure ... -weight 1` and `grid rowconfigure ... -weight 1`, the widget keeps its initial size instead of filling the container. Also use `-sticky ns` (vertical) or `-sticky ew` (horizontal) on the scrollbar so it stretches along its axis.

**The mouse wheel does not go through the scrollbar.** Wheel events go to the widget under the pointer, so whether it reacts to the wheel depends on the widget. Some (like `canvas`) need explicit bindings.

**The thumb fills the whole trough when everything is visible.** The scrollbar never hides itself. To hide it when it is not needed, put a small proc between the widget and the scrollbar:

```tcl
proc hide-when-unneeded {sb first last} {
    if {$first <= 0.0 && $last >= 1.0} {
        grid remove $sb
    } else {
        grid $sb
    }
    $sb set $first $last
}

listbox .f.lb -yscrollcommand [list hide-when-unneeded .f.sb]
```

`grid remove` remembers the grid options, so a plain `grid $sb` puts it back where it was. Keep in mind that the layout changes by the scrollbar's width each time it appears or disappears. tklib also has an `autoscroll` package that does this.

## Official documentation

- [ttk::scrollbar](https://www.tcl-lang.org/man/tcl/TkCmd/ttk_scrollbar.htm)
