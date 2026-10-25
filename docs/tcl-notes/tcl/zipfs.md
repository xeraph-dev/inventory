# zipfs

Tcl 9's virtual filesystem on top of zip archives. Files inside a mounted archive are read with the usual commands (`source`, `open`, `glob`, `file copy`), and an archive appended to an executable lets one file carry a whole application.

## What it is and when to use it

Use it to ship a Tcl/Tk application as a single executable: the code, its packages and resources live in an archive attached to a Tcl or Wish binary. It needs a Tcl built with zipfs enabled.

## Minimal example

Builds an executable carrying a tiny program, then looks inside it:

```tcl
file mkdir vfs
set fd [open vfs/main.tcl w]
puts $fd {puts "hello from [info script]"}
close $fd

zipfs mkimg demo vfs vfs "" [info nameofexecutable]

zipfs mount demo //zipfs:/demo
puts [glob -directory //zipfs:/demo *]    ;# //zipfs:/demo/main.tcl
zipfs unmount //zipfs:/demo
```

## Commands you will use

| Command | What it does |
|---|---|
| `zipfs mkimg $out $dir $strip $password $infile` | Packs `$dir` into an archive and appends it to the executable `$infile`, writing `$out` |
| `zipfs mount $file $mountpoint` | Makes the archive attached to `$file` visible under `$mountpoint` |
| `zipfs unmount $mountpoint` | Removes the mount |

- `$strip` is the leading part of the paths that is removed inside the archive. Passing the same directory as `$dir` stores `vfs/main.tcl` as `main.tcl`.
- `$password` is an empty string for none.
- `$file` in `mount` can be a plain zip or an executable with an archive attached.

## Concepts

- **Mount points live under `//zipfs:/`.** Everything inside a mounted archive is reached with paths like `//zipfs:/demo/main.tcl`.
- **A packed executable runs its own code.** When it starts, the archive attached to it is mounted at `//zipfs:/app`, and the `main.tcl` at its root is run.
- **Paths built from `[info script]` work inside and outside the archive**, so code that locates its files that way runs from a source tree and from a packed executable alike.

## Pitfalls

**The archive is read-only.** Data that must be written (a database, settings) has to go to a real directory on disk.

**Copying out of a mount works like copying from any directory.** `file copy` from a mount to a real directory is how you take files out of an existing executable, for instance to reuse its libraries in a new one.

**Unmount what you mounted.** A mount stays until you remove it or the program ends.

**The mount point must start with `//zipfs:/`.** Any other path is rejected.

## Official documentation

- [zipfs](https://www.tcl-lang.org/man/tcl/TclCmd/zipfs.htm)
