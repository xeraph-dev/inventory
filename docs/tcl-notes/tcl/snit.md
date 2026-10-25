# snit

Snit is a pure-Tcl object system (part of tcllib) built on **delegation** instead of inheritance. This note covers what is needed to build widgets with it: `snit::widget` and `snit::macro`.

## What it is and when to use it

`snit::widget` defines a composite widget ("megawidget"). Snit creates the container (the *hull*) for you, and the widget is a Tk widget in every way: it has a window path, goes in `pack`/`grid`, and is destroyed with `destroy`. Use it for every screen and every reusable piece of UI.

## Minimal example

Save as `counter.tcl` and run it with `wish9.1 counter.tcl`:

```tcl
package require snit

snit::widget counter {
    hulltype ttk::frame

    option -step 1                  ;# local option
    delegate option * to hull       ;# -padding, -style, ...
    delegate method * to hull

    component display
    variable count 0

    constructor args {
        install display using ttk::entry $win.display -textvariable [myvar count]
        ttk::button $win.add -text "+" -command [mymethod increment]
        pack $display $win.add -side left

        $self configurelist $args
    }

    method increment {} {
        incr count $options(-step)
    }
}

pack [counter .c -padding 8 -step 5]
```

What each part does:

- `hulltype ttk::frame`: the container widget. Another one is [ttk::labelframe](../tk/ttk-labelframe.md), for widgets that wrap another one under a title; `frame`, `labelframe` and `toplevel` also exist.
- `option -step 1`: an option owned by the widget, readable as `$options(-step)` inside methods.
- `delegate option * to hull` and `delegate method * to hull`: every option and method the widget does not define itself is forwarded to the hull, so `counter .c -padding 8` works as it would on a `ttk::frame`.
- `component display` + `install display using ...`: declares a child and creates it. Afterwards `$display` is its command.
- `variable count 0`: an instance variable, visible in every method without declaring it again.
- `mymethod increment`: builds a callback that calls the widget's own method.
- `[myvar count]`: see [Variables](#variables). The entry is explained in [ttk::entry](../tk/ttk-entry.md).
- `$self configurelist $args`: applies the options given at creation. See the pitfalls.

## Delegation

A widget can pass options and methods on to a component, so it behaves like it.

```tcl
snit::widget labeled-entry {
    hulltype ttk::labelframe

    component entry

    delegate option -label to hull as -text
    delegate option * to entry
    delegate method * to entry

    constructor args {
        install entry using ttk::entry $win.entry
        pack $entry -fill both -expand yes

        $self configurelist $args
    }
}

pack [labeled-entry .le -label Name -textvariable ::name]
```

- `delegate option -label to hull as -text` exposes the hull's `-text` under another name.
- `delegate option * to entry` and `delegate method * to entry` forward everything else to the entry, so `-textvariable` reaches the entry and the widget has all its methods.
- A locally defined option or method always wins over a `*` delegation, so you can override individual ones.
- Here the hull is a labelframe, so the frame options are not delegated to the hull: they stay with the container, and the options of the content go to the entry.

## Options with a handler

An option with `-configuremethod` runs a method every time it is set, at creation (when passed) and with `configure`. The method receives the option name and the value, and **must store the value itself**:

```tcl
snit::widget titled-label {
    hulltype ttk::frame

    component display

    option -text -configuremethod SetText

    delegate option * to hull
    delegate method * to hull

    constructor args {
        install display using ttk::label $win.display
        pack $display

        $self configurelist $args
    }

    method SetText {option value} {
        set options($option) $value
        $display configure -text $value
    }
}
```

The handler uses `$display`, so the component must exist when the option is applied: that is why `configurelist` goes last.

## Variables

`variable count 0` declares an instance variable; `variable counts -array {a 0 b 0}` declares an array.

`[myvar count]` returns the full name of the instance variable. Use it wherever Tk or another widget needs a variable *name*: `-textvariable`, `trace add variable`, or an option that hands the variable to a child. A plain `count` would be looked up in the global namespace.

## Destructor

Code that runs when the widget is destroyed. Use it to undo what lives outside the widget: [traces](trace.md) on other variables, `after` timers, global state.

```tcl
snit::widget watcher {
    hulltype ttk::frame

    option -source

    constructor args {
        $self configurelist $args
        trace add variable $options(-source) write [mymethod changed]
    }

    destructor {
        catch {trace remove variable $options(-source) write [mymethod changed]}
    }

    method changed args {}
}
```

Wrap the cleanup in `catch` (see [Error handling](error-handling.md)): the destructor may run when the constructor failed halfway, before the thing to undo was created. `mymethod` builds the same command every time, so the same call removes what was added.

## Macros

A `snit::macro` is a command that can be called inside a type definition and generates part of it (options, methods, variables). It is the way to avoid repeating the same boilerplate in many widgets.

```tcl
snit::macro counter-state {} {
    variable count 0

    method increment {} {incr count}
    method reset {} {set count 0}
}

snit::widget clicker {
    hulltype ttk::frame
    counter-state

    delegate option * to hull
    delegate method * to hull

    constructor args {
        $self configurelist $args
    }
}
```

- The macro must be **defined before** the type that uses it is defined, so it has to be sourced first.
- Its body runs while the type is being defined: commands like `option`, `method` and `variable` are available, and what they define becomes part of the type.
- To build code with the macro's arguments, assemble it as text (with `list`, `join`, `lappend`) and pass it to `method` or `option`, as you would build any script.

## Pitfalls

**The default hull is a classic `frame`, not a `ttk::frame`.** A widget without `hulltype ttk::frame` ignores the ttk theme, which shows up as a mismatched background inside a [ttk::notebook](../tk/ttk-notebook.md).

**If you write a constructor, applying options is your job.** Snit only generates `constructor args {$self configurelist $args}` when you do not define one. In your own constructor, forgetting `$self configurelist $args` means options passed at creation (`counter .c -step 5`) are never applied.

**`configurelist` goes last.** Options delegated to a child, and options with a handler that touches a child, can only be applied once that child exists, so call it after the children are created.

**Without the two `delegate ... *` lines the widget only has its own options.** `counter .c -padding 8` fails if nothing delegates `-padding` to the hull.

**Build child paths from `$win`.** `$win` is the Tk window name and never changes. Snit renames the hull and installs its own command in its place, so `$self` may not stay what you expect.

**Callbacks: use `mymethod`, not `[list $self method]`.** `mymethod` keeps working if the instance command is renamed, and it is the form for `-command`, `after`, bindings and traces.

**Declare components before using them.** `install` requires the component name to be declared with `component`, or to appear in a `delegate` statement. For widgets, prefer `install` over a plain `set`: it also initializes the options delegated to the component from the Tk option database.

**Option rules**

- Option names start with a hyphen and cannot contain uppercase letters.
- Local options live in the `$options` array. **Delegated options never do**: they belong to the component they are delegated to.
- If an option has a `-configuremethod`, the method has to store the value in `$options` itself; if it does not, the option never changes.

**Widget lifecycle**

- Destroy with Tk's `destroy $w`. Widgets have no `destroy` method.
- The instance name must be a valid window path, and its parent must already exist.
- A hyphenated type name such as `products-panel` is fine; its Tk class name is derived from it (`Products-panel`).

## Official documentation

- [snit reference](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/modules/snit/snit.md)
- [snit FAQ](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/modules/snit/snitfaq.md), a gentler introduction than the reference
