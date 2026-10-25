# ttk::entry

A single-line text field. The user types in it; your code reads and sets its text through a variable.

## What it is and when to use it

Use it for short free text: a name, a code, a note. For several lines use `text`. This note covers the entry bound to a variable with `-textvariable`, which is the way to read and write its text.

## Minimal example

```tcl
package require Tk

set ::name ""

ttk::entry .e -textvariable ::name
ttk::button .b -text "Show" -command {puts "name = '$::name'"}
ttk::button .c -text "Clear" -command {set ::name ""}

pack .e .b .c -padx 4 -pady 4
```

## Concepts

- **The text lives in the variable.** With `-textvariable` the variable always has the current text, and assigning the variable changes what the entry shows. There is no need to ask the entry for its text.
- **Inside a snit widget** the variable is an instance variable, and its name is obtained with `myvar`: `-textvariable [myvar name]`. See [snit](../tcl/snit.md#variables).

## Pitfalls

**`-textvariable` names a global variable.** An unqualified name is looked up in the global namespace, even if the entry is created inside a proc. A local `set name x` does not touch it, and the entry stays empty. Use `::name`, a namespace-qualified name, or `myvar` inside a snit widget.

**The variable wins when it is attached.** If the variable already exists, the entry shows its value; if it does not exist, the entry starts empty and any text inserted before is lost. Set the variable before creating the entry.

**Assign the variable to change the text.** `set ::name ""` empties the entry. Do not `unset` the variable: the entry is left without a variable to read from.

## Official documentation

- [ttk::entry](https://www.tcl-lang.org/man/tcl/TkCmd/ttk_entry.htm)
