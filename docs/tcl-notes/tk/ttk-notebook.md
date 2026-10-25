# ttk::notebook

A tabbed container: it holds several windows (panes) and shows one at a time, with a tab for each along the top.

## What it is and when to use it

Use it to split a window into top-level sections that the user switches between. Each pane is an ordinary widget that you create yourself, as a child of the notebook, and then `add` to it.

## Minimal example

```tcl
package require Tk

ttk::notebook .nb
pack .nb -fill both -expand yes

foreach {name title} {products Products sales Sales} {
    ttk::frame .nb.$name -padding 10
    ttk::label .nb.$name.l -text "$title panel"
    pack .nb.$name.l
    .nb add .nb.$name -text $title
}
```

## Commands you will use

| Command | What it does |
|---|---|
| `$nb add $pane -text $title` | Appends a tab for `$pane`, with its title |

## Pitfalls

**The notebook is as big as its biggest pane.** Its requested size is the largest requested width and height among all panes, plus the tab bar. One large pane raises the minimum size of the whole window, and it does so even while that pane is not visible. If the window's minimum size is taken from the requested size of its content, every pane counts.

**Create each pane as a child of the notebook** (`$nb.name`), and create it before calling `add`.

## Official documentation

- [ttk::notebook](https://www.tcl-lang.org/man/tcl/TkCmd/ttk_notebook.htm)
