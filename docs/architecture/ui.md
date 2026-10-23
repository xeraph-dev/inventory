# UI

How screens are built: widget pattern, structure and how to add a screen.

## Structure

The window holds a single root widget, which contains a notebook. Each tab of
the notebook is a panel, one per section of the app. A panel can be built from
smaller widgets (a table, a form), each one a widget of its own.

```
root widget
└── notebook
    └── panel (one per section)
        └── smaller widgets (table, form, ...)
```

## The widget pattern

Every widget is a `snit::widget` whose hull is a `ttk::frame`, with the same boilerplate:

```tcl
snit::widget my-widget {
    hulltype ttk::frame

    delegate option * to hull
    delegate method * to hull

    constructor args {
        # create the children here

        $self configurelist $args
    }
}
```

- `delegate ... to hull` makes the widget behave like a normal `ttk::frame` (for example, accepts `-padding`).
- `$self configurelist $args` goes **last** in the constructor, once the children exist.
- Create children as `$win.<name>`, and keep the ones you need later as snit components (`component tree`, `install tree using ...`).

## Where files go

One directory per area, one file per widget, named after the widget. The parts
of a panel live next to it.

## Adding a tab

1. Create the panel widget as above.
2. Add it to the notebook in the constructor of the root widget:

```tcl
$tabs add [my-panel $tabs.my_section] -text [mc my_section]
```

3. Add its title key to the catalogs (see [Internationalization](i18n.md)).

The window's minimum size is calculated from the initial size of the whole
app, so a large panel raises the minimum size of the window.

See [Adding a feature](adding-a-feature.md) for the complete flow.
