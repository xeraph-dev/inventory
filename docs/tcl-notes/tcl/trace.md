# trace

Runs a command automatically every time a variable is written.

## What it is and when to use it

Use it to react to a change of a variable without the code that changes it knowing about you, for instance to refresh a table when a counter goes up.

## Minimal example

```tcl
proc on-change {name1 name2 op} {
    puts "changed: $name1 ($name2) by $op"
}

array set counts {items 0}
trace add variable counts(items) write on-change

incr counts(items)
set counts(items) 10

trace remove variable counts(items) write on-change
incr counts(items)   ;# prints nothing
```

## Commands you will use

| Command | What it does |
|---|---|
| `trace add variable $name write $command` | Calls `$command` after every write to the variable |
| `trace remove variable $name write $command` | Removes it |

`$name` can be a plain variable or one element of an array, written `array(element)`.

## Concepts

- **Three arguments are appended.** The command is called as `$command name1 name2 op`: the variable (or array) name, the element (empty for plain variables) and `write`. A command that does not need them must accept and ignore them (`args`).
- **Writes through an alias count.** A change made through an `upvar` link fires the trace of the original variable, from any proc. See [upvar](upvar.md).
- **It only fires on writes.** A trace added on a variable does not run when the variable is created; call the command yourself once if you need the initial state.

## Pitfalls

**`remove` has to match exactly.** It removes the trace whose operations and command are the same ones you added. With a command built by [snit](snit.md)'s `mymethod`, calling `mymethod` again builds the same command, so the same call works.

**A trace keeps a command alive after its object is gone.** If the command belongs to a widget, remove the trace when the widget is destroyed (see [Destructor](snit.md#destructor)), or the next write calls a command that no longer exists.

**An error in the command breaks the write.** The error is raised from the `set` or `incr` that triggered it, in the code of whoever wrote the variable.

**The command runs inside the write.** Everything that happens in it happens before the writer continues.

## Official documentation

- [trace](https://www.tcl-lang.org/man/tcl/TclCmd/trace.htm)
