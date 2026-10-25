# Tcl/Tk notes

General notes on Tcl and Tk features that the official documentation explains poorly.

## Scope

A note covers **only what the project uses**: a command, option or widget the
project does not use is not documented, so nothing here is mistaken for part of
the project's toolbox. When the project starts using something new, its note
grows with it; when the project stops using a whole topic, its note is deleted.

No note refers to the project's code, and the examples are new, self-contained
snippets. How Inventory itself is built lives in [architecture/](../architecture/).

## Layout

| Folder | What goes in it |
|---|---|
| `tk/` | Widgets and Tk behavior (`ttk::notebook`, `ttk::treeview`, `ttk::scrollbar`, ...) |
| `tcl/` | The language and its libraries (`snit`, `sqlite3`, ...) |

One note per topic, named after the topic (`tk/ttk-notebook.md`, `tcl/snit.md`).

## Notes are independent

Each note covers a single topic and can be read, and its examples run, without
opening any other note. When two topics are used together (a treeview and a
scrollbar, for example), each note carries its own short snippet for the
combination, and the two notes link to each other for the details. A note never
explains the other topic.

## Template

Every note follows this structure, and leaves out a section if it has nothing to say:

1. **What it is and when to use it**: a couple of lines.
2. **Minimal example**: complete enough to paste and run.
3. **Options and pitfalls**: the surprising behavior, the typical mistakes, and the error messages with their cause. This is the main part.
4. **Official documentation**: a link.

## Index

### tk/

- [events](tk/events.md): virtual events, to announce that something happened.
- [ttk::entry](tk/ttk-entry.md): single-line text input bound to a variable.
- [ttk::labelframe](tk/ttk-labelframe.md): frame with a title, to group widgets.
- [ttk::notebook](tk/ttk-notebook.md): tabbed container.
- [ttk::scrollbar](tk/ttk-scrollbar.md): how to connect a scrollbar to a scrollable widget.
- [ttk::treeview](tk/ttk-treeview.md): tables of records.
- [tk_messageBox](tk/tk-messagebox.md): modal dialogs to inform or ask yes/no.

### tcl/

- [error handling](tcl/error-handling.md): `try` and `catch`.
- [msgcat](tcl/msgcat.md): message catalogs, to translate text.
- [snit](tcl/snit.md): object system for building widgets.
- [sqlite3](tcl/sqlite3.md): the Tcl interface to SQLite.
- [trace](tcl/trace.md): run a command when a variable is written.
- [upvar](tcl/upvar.md): use a variable by its name from another scope.
- [zipfs](tcl/zipfs.md): virtual filesystem on zip archives; single-file executables.
