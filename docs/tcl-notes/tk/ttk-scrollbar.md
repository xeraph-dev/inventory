# ttk::scrollbar

A bar that shows which part of a larger content is visible and lets the user move it. It holds no content: it is wired to another widget that does.

## What it is and when to use it

Use it with a widget that can scroll vertically, such as [ttk::treeview](ttk-treeview.md). Those widgets never draw a scrollbar themselves; you create one and connect the two. This note covers the vertical scrollbar.

## Minimal example

A treeview with a vertical scrollbar:

```tcl
package require Tk

ttk::frame .f
pack .f -fill both -expand yes

ttk::treeview .f.tv -show headings -columns {name} -yscrollcommand [list .f.sb set]
ttk::scrollbar .f.sb -orient vertical -command [list .f.tv yview]
.f.tv heading name -text Name

pack .f.tv -side left -fill both -expand yes
pack .f.sb -side right -fill y

for {set i 1} {$i <= 100} {incr i} {.f.tv insert {} end -values [list "Item $i"]}
```

`-yscrollcommand` and `yview` belong to the scrolled widget; see [ttk::treeview](ttk-treeview.md#scrolling) for its side of the connection.

## How the connection works

Two callbacks, one in each direction:

- **Widget to scrollbar.** Whenever the visible part changes, the widget calls its `-yscrollcommand` with two fractions between 0 and 1 (where the visible part starts and ends). `$sb set first last` stores them and redraws the thumb.
- **Scrollbar to widget.** When the user drags the thumb or clicks the arrows or the trough, the scrollbar calls its `-command` with extra arguments appended (`moveto 0.4`, `scroll 1 units`, `scroll 1 pages`). The widget's own `yview` method understands them.

That is why the wiring is always `-yscrollcommand [list $sb set]` on the widget and `-command [list $widget yview]` on the scrollbar.

## Pitfalls

**Both directions are needed.** Without `-yscrollcommand` the thumb never moves or resizes; without `-command` dragging the thumb does nothing.

**Use `list` to build both callbacks.** `[list .f.sb set]` keeps the command as a proper Tcl list, whatever the widget path contains.

**The scrollbar is a sibling of the scrolled widget, not its child.** Create both in the same container so one geometry manager arrangement controls them.

**Give the scrollbar `-fill y`.** With `pack`, the scrollbar must stretch along its axis (`-side right -fill y`), and the scrolled widget takes the rest (`-side left -fill both -expand yes`).

**The thumb fills the whole trough when everything is visible.** The scrollbar never hides itself.

## Official documentation

- [ttk::scrollbar](https://www.tcl-lang.org/man/tcl/TkCmd/ttk_scrollbar.htm)
