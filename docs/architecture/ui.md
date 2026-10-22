# UI

How screens are built: widget pattern, structure and how to add a screen.

## Structure

```
.app                 (app: ttk::frame)
└── tabs             (ttk::notebook)
    └── products     (products-panel: ttk::frame)
```

`main.tcl` creates `.app` and packs it. `app` holds a notebook, and each tab is a
panel widget.

## The widget pattern

Every widget is a `snit::widget` whose hull is a `ttk::frame`, with the same boilerplate.
`products-panel` is the smallest example:

```tcl
snit::widget products-panel {
    hulltype ttk::frame

    delegate method * to hull
    delegate option * to hull

    constructor args {
        $self configurelist $args
    }
}
```

- `delegate ... to hull` makes the widget behave like a normal `ttk::frame` (for example, accepts `-padding`).
- `$self configurelist $args` goes **last** in the constructor, once the children exist.
- Create children as `$win.<name>`, and keep the ones you need later as snit components (`component tabs`, `install tabs using ...`).

## Where files go

One directory per area under `src/`, one file per widget, file named after the widget:
`src/products/products-panel.tcl`.

## Adding a tab

1. Create the panel widget as above.
2. Add it to the notebook in the constructor of `src/app.tcl`:

```tcl
$tabs add [products-panel $tabs.products] -text [mc products]
```

3. Add its title key to the catalogs (see [Internationalization](i18n.md)).

The window's minimum size is calculated from the initial size of the whole
app, so a large panel raises the minimum size of the window.

See [Adding a feature](adding-a-feature.md) for the complete flow.
