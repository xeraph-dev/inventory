# ttk::entry

A single-line text field. The user types in it; your code reads, sets and validates its value.

## What it is and when to use it

Use it for short free text: a name, a code, a number, a search box. For several lines use `text`; to pick from a fixed set use `ttk::combobox`.

## Minimal example

An entry that only accepts digits, and a button that reads it:

```tcl
package require Tk

proc is-digits {text} {
    regexp {^[0-9]*$} $text
}

ttk::label .l -text "Quantity:"
ttk::entry .e -width 12 -textvariable ::qty -validate key -validatecommand {is-digits %P}
ttk::button .b -text "Show" -command {puts "qty = '$::qty'"}

grid .l .e .b -padx 4 -pady 8
focus .e
```

## Concepts

- **The value** lives in the entry. You can read it with `$e get`, change it with `insert` and `delete`, or link it to a variable with `-textvariable`: the variable always has the current text, and setting the variable changes the text.
- **States.** `normal` (editable), `readonly` (can be selected and copied, but not edited) and `disabled` (neither). A readonly or disabled entry ignores `insert` and `delete`, but setting its `-textvariable` still changes the text.
- **Validation.** The entry can check its text and veto the change. It is configured with three options:

| Option | Meaning |
|---|---|
| `-validate` | When to validate: `none` (default), `key` (before each edit), `focusin`, `focusout`, or `all` |
| `-validatecommand` | A script that returns a boolean: true accepts, false rejects |
| `-invalidcommand` | A script called when `-validatecommand` returned false |

Before the script runs, Tk replaces these codes in it:

| Code | Replaced by |
|---|---|
| `%P` | The text the entry would have if the edit is accepted |
| `%s` | The text the entry has now |
| `%S` | The text being inserted or deleted |
| `%d` | `1` for an insertion, `0` for a deletion, `-1` for anything else (focus, `validate`) |
| `%i` | Index where the insertion or deletion starts |
| `%v` | The current value of `-validate` |
| `%V` | What triggered this call: `key`, `focusin`, `focusout` or `forced` |
| `%W` | The path of the entry |

## Commands you will use

| Command | What it does |
|---|---|
| `$e get` | Returns the text |
| `$e insert $index $text` | Inserts text before the index |
| `$e delete $first ?$last?` | Deletes from `$first` up to, but not including, `$last` (one character if omitted); `0 end` clears it |
| `$e icursor $index` | Moves the insertion cursor |
| `$e selection range $first $last` | Selects text; also `selection clear` and `selection present` |
| `$e validate` | Runs the validation now; returns 1 or 0 and sets or clears the `invalid` state |
| `$e state $flags` / `$e instate $flags` | Sets or tests state flags (`disabled`, `readonly`, `invalid`, ...); a `!` clears one |

An index is a number, `end`, `insert` (the cursor), `sel.first`, `sel.last` or `@x` (a pixel position).

Useful options: `-width` (in characters, default 20), `-show` (character to display instead of the text, for passwords), `-justify`, `-state`, `-font`, `-exportselection`.

## Pitfalls

**`-textvariable` names a global variable.** An unqualified name is looked up in the global namespace, even if the entry is created inside a proc. A local `set myvar x` does not touch it, and the entry stays empty. Use `::name` or a namespace-qualified name.

**The variable wins when it is attached.** If you give `-textvariable` a variable that does not exist, the entry starts empty, and text you had inserted before is lost. Set the variable before creating the entry, or before attaching it.

**Changing the variable does not run the validation.** `insert`, `delete` and typing are validated; assigning the `-textvariable` is not. Do not rely on `-validatecommand` to clean a value you set yourself.

**The validation script must return a boolean.** If it raises an error, or returns something that is not a boolean (`expected boolean value but got "maybe"`), the edit is rejected and `-validate` is silently reset to `none`: from then on nothing is validated. If the entry stops validating, look for an error in the script.

**`key` validation sees the whole result, including the empty string.** A rule that does not accept `""` stops the user from deleting the last character. A paste or an insertion of several characters is accepted or rejected as a whole, not character by character.

**`key` cannot tell a partial value from a wrong one.** While typing a decimal, `1.` has to be accepted even though it is not a finished number. Use `key` for what may never be typed (letters in a number field), and check the finished value when the user leaves the field or presses a button, with `$e validate`.

**A failed `focusout` validation does not revert the text.** The value stays, the entry gets the `invalid` state and `-invalidcommand` runs. The `invalid` state is cleared by the next successful validation. Test it with `$e instate invalid`.

**The `invalid` state is not visible by default.** To show it, map the state in the style. Native themes (macOS, Windows) may ignore some of these options, so test it on each platform:

```tcl
ttk::style map TEntry -fieldbackground \
    [list invalid #ffd9d9 {*}[ttk::style map TEntry -fieldbackground]]
```

**`-state` and `state` are not the same thing.** `-state disabled` is reflected by `cget -state`; `$e state disabled` is not (`cget -state` still says `normal`). To know whether an entry is disabled, always use `$e instate disabled`.

**`-width` counts characters, not pixels.** The entry asks for that width and does not grow with the window. To make it stretch, use `grid ... -sticky ew` with a column weight, or `pack -fill x -expand yes`.

**`get` returns the real text when `-show` is set.** Only the display changes.

**Percent codes are replaced in the script text.** Keep the script a single call to a proc and pass only the codes you need (`{is-digits %P}`, or `[list is-digits %P]`); do not write several commands with `%` codes inside.

## Official documentation

- [ttk::entry](https://www.tcl-lang.org/man/tcl/TkCmd/ttk_entry.htm)
