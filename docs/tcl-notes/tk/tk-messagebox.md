# tk_messageBox

A modal dialog with a message, an icon and a few buttons. It returns the button the user pressed.

## What it is and when to use it

Use it to tell the user something (an error) or to ask a yes/no question (confirm a delete) before going on.

## Minimal example

```tcl
package require Tk

ttk::button .b -text "Delete" -command {
    set answer [tk_messageBox -type yesno -icon warning -default no \
        -title "Delete" -message "Delete this item? This cannot be undone."]
    if {$answer eq "yes"} {puts "deleted"} else {puts "kept"}
}
pack .b -padx 20 -pady 20
```

## Options you will use

| Option | Values |
|---|---|
| `-type` | `ok` (one button) or `yesno` (two buttons) |
| `-icon` | `error`, `warning` |
| `-default` | The button that is selected by default (`ok`, `yes`, `no`); must be one of the buttons of `-type` |
| `-title` | The window title |
| `-message` | The text |

The result is the name of the pressed button in lowercase: `ok`, `yes` or `no`.

## Pitfalls

**It blocks.** The command does not return until the user answers, and the rest of the application waits.

**Compare the result as text.** `$answer eq "yes"`, in lowercase.

**For destructive questions, make `no` the default** (`-default no`), so that pressing Enter does not confirm.

**The text is not translated for you.** Pass already translated strings, for example from [msgcat](../tcl/msgcat.md). The standard buttons ("OK", "Yes", "No") are drawn by the system, in the system language.

**`-title` may be ignored.** Some platforms (macOS) show the dialog without a title.

## Official documentation

- [tk_messageBox](https://www.tcl-lang.org/man/tcl/TkCmd/messageBox.htm)
