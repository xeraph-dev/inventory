# Virtual events

How a widget announces that something happened, so that whoever created it can react, without the widget knowing who that is.

## What it is and when to use it

A virtual event is an event with a name you choose, written between double angle brackets (`<<ItemSelected>>`). One side generates it with `event generate`, the other side listens with `bind`. Use it to let a widget notify its surroundings; Tk widgets do the same (`<<TreeviewSelect>>` in [ttk::treeview](ttk-treeview.md)).

## Minimal example

```tcl
package require Tk

ttk::button .b -text "Pick 42"
ttk::label .l -text "nothing yet"
pack .b .l -padx 8 -pady 4

# The listener
bind .b <<ItemPicked>> {.l configure -text "picked: %d"}

# The announcer
.b configure -command {event generate .b <<ItemPicked>> -data 42}
```

## Concepts

- **No declaration.** Any name between `<<` and `>>` is a valid virtual event; nothing has to be registered.
- **`-data`.** `event generate $w <<Name>> -data $value` attaches one string to the event. In the binding script, `%d` is replaced by it.
- **Synchronous.** `event generate` runs the bound script immediately and returns when it is done.

## Commands you will use

| Command | What it does |
|---|---|
| `event generate $w <<Name>> ?-data $string?` | Generates the event on a widget |
| `bind $w <<Name>> $script` | Runs `$script` when the event reaches that widget |

## Pitfalls

**Bind on the widget that generates the event.** The event is delivered to that widget only; a binding on its parent frame, or on the window, does not see it.

**Percent codes are replaced in the script text.** `%d` is substituted before the script runs. Keep the script a single call built with `list` (`[list $form edit %d]`) instead of several commands with `%` codes.

**`-data` is one string.** To send several values, send a list and take it apart in the listener. When there is nothing to send, omit `-data`: `%d` then arrives as an empty string, and the listener has to handle it.

**The listener runs before `event generate` returns.** If it changes the state of the widget that generated the event, that change is already done when the announcer continues.

**A widget can receive its own event again.** When the listener acts on the widget that generated the event (selecting a row from code, for instance), a new event may come back. Make the listener harmless to run twice for the same value.

## Official documentation

- [event](https://www.tcl-lang.org/man/tcl/TkCmd/event.htm)
- [bind](https://www.tcl-lang.org/man/tcl/TkCmd/bind.htm)
