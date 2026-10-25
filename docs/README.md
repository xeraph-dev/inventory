# Inventory documentation

Documentation for **Inventory**, a simple inventory management desktop app
(products, purchases, sales) built with Tcl/Tk 9.1 and SQLite.

It is written for the maintainer and for anyone who wants to continue
working on the project or contribute to it.

## Sections

| Section | What it answers |
|---|---|
| [getting-started/](getting-started/) | How do I set up my machine, run the app and build it? |
| [architecture/](architecture/) | How is this project put together? |
| [tcl-notes/](tcl-notes/) | How does this Tcl/Tk feature work? (general notes, one per topic) |
| `conventions/` | What rules does the code follow? *(not written yet)* |

## Start here

1. [Setup](getting-started/setup.md): install Tcl, tcllib, tklib and lay out the project.
2. [Tcl and Tk from source](getting-started/tcl-from-source.md): compile the static Tcl/Tk the build needs.
3. [Running](getting-started/running.md): launch the app in development.
4. [Building](getting-started/building.md): produce single-file executables.
5. [Architecture overview](architecture/overview.md): how the project is put together.

## Writing conventions for these docs

- Written in English, in Markdown.
- Every document starts with one or two lines saying what it covers.
- **Never refer to existing code** (files, procs, widgets, variables or constants of the project): the code changes and the docs would silently go stale. When an example is needed, write a new, self-contained code block that shows the pattern. The only exception is [getting-started/](getting-started/), which names the files you run (entry point, build script) and the top-level directories.
- **[tcl-notes/](tcl-notes/) only documents what the project uses.** Commands, widgets and options the project does not use are left out, so nothing there is mistaken for part of the project.
- **Documents that depend on each other link to each other**, in both directions, with real relative links (and anchors when pointing to a section).
- Link to other documents instead of repeating their content.
