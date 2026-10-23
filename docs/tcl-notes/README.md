# Tcl/Tk notes

General notes on Tcl and Tk features that the official documentation explains poorly.

Nothing here depends on this project. How Inventory itself is built lives in
[architecture/](../architecture/).

## Layout

| Folder | What goes in it |
|---|---|
| `tk/` | Widgets and Tk behavior (`ttk::notebook`, `ttk::treeview`, `ttk::scrollbar`, validation, ...) |
| `tcl/` | The language and its libraries (`snit`, `namespace ensemble`, `uplevel`, `msgcat`, ...) |

One note per topic, named after the topic (`tk/ttk-notebook.md`, `tcl/snit.md`).

## Notes are independent

Each note covers a single topic and can be read, and its examples run, without
opening any other note. When two topics are used together (a treeview and a
scrollbar, for example), each note carries its own short snippet for the
combination and links to the other one for the details. A note never explains
the other topic.

## Template

Every note follows this structure, and leaves out a section if it has nothing to say:

1. **What it is and when to use it**: a couple of lines.
2. **Minimal example**: complete enough to paste and run.
3. **Options and pitfalls**: the surprising behavior, the typical mistakes, and the error messages with their cause. This is the main part.
4. **In this project**: where it is used, with a link to [architecture/](../architecture/).
5. **Official documentation**: a link.

## Index

### tk/

- [ttk::notebook](tk/ttk-notebook.md): tabbed container, the base of the app's main window.
- [ttk::scrollbar](tk/ttk-scrollbar.md): how to connect a scrollbar to any scrollable widget.
- [ttk::treeview](tk/ttk-treeview.md): tables of records.

### tcl/

- [snit](tcl/snit.md): the object system used for every widget in the project.
