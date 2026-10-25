# upvar

Makes a local variable an alias of a variable that lives somewhere else, so the code can use it by a local name.

## What it is and when to use it

Use it when a proc or method receives the **name** of a variable (as an argument or an option) and has to read or write that variable. After `upvar`, the local name and the original are the same variable.

## Minimal example

```tcl
proc bump {counterName} {
    upvar $counterName counter
    incr counter
}

proc bump-key {arrayName key} {
    upvar $arrayName data
    incr data($key)
}

set hits 0
bump hits
puts $hits                 ;# 1

array set stats {a 0 b 0}
bump-key stats a
puts $stats(a)             ;# 1
```

## Concepts

- `upvar $name local` links `local` to the variable called `$name`.
- The linked name can be a scalar or a whole **array**: `upvar $arrayName data` lets you write `data(key)`.
- **Traces follow the link.** Writing through the alias is writing the original, so a write trace set on the original fires. See [trace](trace.md).

## Pitfalls

**The name is resolved from the caller's frame.** An unqualified name refers to a variable in the scope of whoever called the proc, which is rarely where the variable lives. Pass fully qualified names (`::counts`, `::ns::counts`), or names produced by a tool that qualifies them, like `myvar` in [snit](snit.md#variables).

**The local name must be free.** `upvar` fails if a variable with that local name already exists in the proc.

**Without the link, `incr` fails.** `incr counter` on a name that was never linked raises `no such variable`; the alias has to be created in each proc that needs it, since it only lives as long as the proc call.

## Official documentation

- [upvar](https://www.tcl-lang.org/man/tcl/TclCmd/upvar.htm)
