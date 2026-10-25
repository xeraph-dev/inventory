# Error handling: try and catch

How to react to an error raised by a command instead of letting it stop the program.

## What it is and when to use it

- `try ... on error` runs a script and, if it raises an error, runs a handler. Use it when you want to look at the error and decide: show a message, or pass it on.
- `catch` runs a script and swallows any error. Use it only where a failure is acceptable, typically cleanup.

## Minimal example

```tcl
proc to-int {text} {
    try {
        expr {int($text)}
    } on error {msg opts} {
        puts "not a number: $msg"
        return -1
    }
}

puts [to-int 12]     ;# 12
puts [to-int abc]    ;# prints the message, then -1

catch {file delete -force no-such-dir/no-such-file}
```

## try

```tcl
try {
    ...script...
} on error {msg opts} {
    ...handler...
}
```

- `msg` is the error message; `opts` is a dictionary with the details (error code, stack trace).
- When there is no error, the result of `try` is the result of the script. With an error, it is the result of the handler.
- `return` inside the handler returns from the **enclosing proc**, as it would anywhere else.
- To pass an error on without changing it, re-raise it with its options:

```tcl
} on error {msg opts} {
    if {[regexp {^something I know} $msg]} {
        puts "handled"
    } else {
        return -options $opts $msg
    }
}
```

## catch

`catch {script}` runs the script and returns 1 if it raised an error, 0 if not. It does not tell you what went wrong when used this way.

```tcl
catch {trace remove variable ::state write ::on-change}
```

## Pitfalls

**Re-raise with `return -options $opts $msg`, not with `error $msg`.** The second one starts a new error and loses the original code and stack trace.

**A script without a matching handler still fails.** If the error is not matched by any `on error`, it keeps going up as if there were no `try`.

**An error inside the handler is not caught by the same `try`.**

**`catch` hides typos.** It swallows every error, including a misspelled command name. Use it for one command whose failure you really do not care about, and use `try` when you need to tell errors apart.

**Matching on the message text is fragile.** The text of an error can change between versions. Match the smallest part you need, anchored at the start (`^`), and re-raise everything you do not recognize. For the messages SQLite raises, see [sqlite3](sqlite3.md#pitfalls).

## Official documentation

- [try](https://www.tcl-lang.org/man/tcl/TclCmd/try.htm)
- [catch](https://www.tcl-lang.org/man/tcl/TclCmd/catch.htm)
