# ttk::labelframe

A frame with a border and a title, to group related widgets.

## What it is and when to use it

Use it to group a widget or a few widgets under a caption. It is a container: the widgets inside are created as its children. It is also useful as the hull of a [snit](../tcl/snit.md) widget that wraps another one with a title.

## Minimal example

```tcl
package require Tk

ttk::labelframe .lf -text "Name"
ttk::entry .lf.e -textvariable ::name
pack .lf.e -fill x
pack .lf -padx 8 -pady 8
```

## Options you will use

| Option | Meaning |
|---|---|
| `-text` | The title shown on the border |

## Pitfalls

**The children belong to the labelframe.** Create them as `.lf.name` and arrange them with a geometry manager inside it; arranging the labelframe itself is done separately, in its own parent.

**Use `ttk::labelframe`, not `labelframe`.** The classic widget ignores the theme and looks out of place next to ttk widgets, in a [ttk::notebook](ttk-notebook.md), for instance.

## Official documentation

- [ttk::labelframe](https://www.tcl-lang.org/man/tcl/TkCmd/ttk_labelframe.htm)
