# snit

Snit is a pure-Tcl object system (part of tcllib) built on **delegation** instead of inheritance. This note covers what you need to build widgets with it.

## What it is and when to use it

| Command | Use it for |
|---|---|
| `snit::widget` | A composite widget ("megawidget"). Snit creates the container (the *hull*) for you. This is what screens use. |
| `snit::widgetadaptor` | Specializing one existing widget (for example an `entry` with extra behavior). You create the hull yourself with `installhull using ...`. |
| `snit::type` | Objects that are not widgets (stores, services). Created with `mytype name` or `mytype %AUTO%`. |

A `snit::widget` is a Tk widget in every way: it has a window path, goes in `pack`/`grid`, and is destroyed with `destroy`.

## Minimal example

Save as `counter.tcl` and run it with `wish9.1 counter.tcl`:

```tcl
package require snit

snit::widget counter {
    hulltype ttk::frame

    option -step 1                  ;# local option
    delegate option * to hull       ;# -padding, -style, ...
    delegate method * to hull

    component label
    variable count 0

    constructor args {
        install label using ttk::label $win.label -text 0
        ttk::button $win.add -text "+" -command [mymethod increment]
        pack $win.label $win.add -side left

        $self configurelist $args
    }

    method increment {} {
        incr count $options(-step)
        $label configure -text $count
    }
}

pack [counter .c -padding 8 -step 5]
```

What each part does:

- `hulltype ttk::frame`: the container widget. Allowed hulltypes are `frame` (the default), `toplevel`, `labelframe`, and their `ttk::` equivalents.
- `option -step 1`: an option owned by the widget, readable as `$options(-step)` inside methods.
- `delegate option * to hull` and `delegate method * to hull`: every option and method the widget does not define itself is forwarded to the hull, so `counter .c -padding 8` works as it would on a `ttk::frame`.
- `component label` + `install label using ...`: declares a child and creates it. Afterwards `$label` is its command.
- `variable count 0`: an instance variable, visible in every method without declaring it again.
- `mymethod increment`: builds a callback that calls the widget's own method.

## Pitfalls

**The default hull is a classic `frame`, not a `ttk::frame`.** A widget without `hulltype ttk::frame` ignores the ttk theme, which shows up as a mismatched background inside a `ttk::notebook`.

**If you write a constructor, applying options is your job.** Snit only generates `constructor args {$self configurelist $args}` when you do not define one. In your own constructor, forgetting `$self configurelist $args` means options passed at creation (`counter .c -step 5`) are never applied.

**`configurelist` goes last.** Options delegated to a child can only be applied once that child exists, so call it after the children are created.

**Without the two `delegate ... *` lines the widget only has its own options.** `counter .c -padding 8` fails if nothing delegates `-padding` to the hull. A locally defined method or option always wins over a `*` delegation, so you can override individual ones.

**Build child paths from `$win`.** `$win` is the Tk window name and never changes. Snit renames the hull and installs its own command in its place, so `$self` may not stay what you expect.

**Callbacks: use `mymethod`, not `[list $self method]`.** `mymethod` keeps working if the instance command is renamed, and it is the form for `-command`, `after`, bindings and traces.

**Declare components before using them.** `install` requires the component name to be declared with `component`, or to appear in a `delegate` statement. For widgets, prefer `install` over a plain `set`: it also initializes the options delegated to the component from the Tk option database.

**Option rules**

- Option names start with a hyphen and cannot contain uppercase letters.
- Local options live in the `$options` array. **Delegated options never do**; use `[$self cget -padding]`.
- If an option has `-configuremethod`, `-cgetmethod` or `-validatemethod`, use `configure` and `cget` rather than touching `$options`, or you bypass the handler.
- `-readonly yes` means the option can only be set at creation.

**Widget lifecycle**

- Destroy with Tk's `destroy $w`. Widgets have no `destroy` method.
- The instance name must be a valid window path, and its parent must already exist.
- `%AUTO%` works for `snit::type` but not for widgets.
- A hyphenated type name such as `products-panel` is fine; its Tk class name is derived from it (`Products-panel`).

## Official documentation

- [snit reference](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/modules/snit/snit.md)
- [snit FAQ](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/modules/snit/snitfaq.md), a gentler introduction than the reference
