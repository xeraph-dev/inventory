# ttk::notebook

A tabbed container: it holds several windows (panes) and shows one at a time, with a tab for each along the top.

## What it is and when to use it

Use it to split a window into top-level sections that the user switches between. Each pane is an ordinary widget (usually a frame) that you create yourself and then `add` to the notebook.

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

bind .nb <<NotebookTabChanged>> {puts "showing: [.nb tab current -text]"}
```

## Commands you will use

| Command | What it does |
|---|---|
| `$nb add $pane ?-option value ...?` | Appends a tab for `$pane` |
| `$nb insert $pos $pane ...` | Inserts a tab at an index, `end`, or before an existing pane |
| `$nb select ?$tab?` | Without argument, returns the selected pane; with one, selects it |
| `$nb tab $tab ?-option ?value??` | Reads or changes a tab's options |
| `$nb tabs` | Lists the panes, in tab order |
| `$nb forget $tab` | Removes the tab |
| `$nb hide $tab` | Hides the tab; `add` brings it back |

A `$tab` can be a pane path, an index, `current` or `end`.

Tab options: `-text`, `-image`, `-compound`, `-state` (`normal`, `disabled`, `hidden`), `-sticky`, `-padding`, `-underline`.

## Pitfalls

**The notebook is as big as its biggest pane.** Its requested size is the largest requested width and height among all panes, plus the tab bar. One large pane raises the minimum size of the whole window, and it does so even while that pane is not visible. To set the size yourself, use the notebook's `-width` and `-height`; they size the pane area, so the tab bar is added on top (and a wide tab bar can still make the notebook wider).

**`forget` does not destroy the pane.** It only removes the tab; the widget stays alive. `destroy` it yourself if you will not add it again.

**Hidden and disabled tabs are still in `tabs`.** A `hidden` tab is not shown but is still listed, so a loop over `$nb tabs` will see it. Selecting a `disabled` tab does not raise an error: the call is silently ignored and the current tab stays selected.

**`<<NotebookTabChanged>>` also fires when the first tab is added**, not only when the user switches. Do not assume the UI is fully built when your handler runs. Read the current tab with `$nb tab current -text` or `$nb select`; the event has no data of its own.

**Keyboard traversal is opt-in.** Call `ttk::notebook::enableTraversal $nb` to get Control-Tab and mnemonics from `-underline`. The Tk manual states that it only works properly if every pane is a direct child of the notebook, so create panes as `$nb.name`.

## Official documentation

- [ttk::notebook](https://www.tcl-lang.org/man/tcl/TkCmd/ttk_notebook.htm)
