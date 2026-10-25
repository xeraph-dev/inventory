# msgcat

Tcl's message catalogs: user-visible text is looked up by key in a catalog per language, instead of being written in the code.

## What it is and when to use it

Use it for every text the user reads (labels, buttons, messages). The code asks for a key with `mc`, and the catalog of the active language supplies the text.

## Minimal example

```tcl
package require msgcat
namespace import msgcat::*

mclocale es
mcset es greeting "Hola"
mcset es items.count "%d productos"

puts [mc greeting]        ;# Hola
puts [mc items.count 3]   ;# 3 productos
puts [mc missing.key]     ;# missing.key
```

`namespace import msgcat::*` makes `mc`, `mcset`, `mcload` and `mclocale` available without the prefix.

## Catalog files

A catalog is a file of `mcset` lines, one file per language, named after the locale in lowercase (`es.msg`, `pt_br.msg`):

```tcl
mcset es greeting "Hola"
mcset es items.count "%d productos"
```

`mcload $dir` loads, from a directory, the files for the current locale and for its less specific forms (for `es_ES`: `es_es.msg`, then `es.msg`). It returns **how many files it loaded**, which tells you whether there was a catalog for the language:

```tcl
if {![mcload $dir]} {
    mclocale en
    mcload $dir
}
```

Files are read as UTF-8.

## Commands you will use

| Command | What it does |
|---|---|
| `mc $key ?$arg ...?` | Returns the text of the key in the current locale; extra arguments are inserted with `format` |
| `mcset $locale $key $text` | Defines a text (this is what catalog files contain) |
| `mcload $dir` | Loads the catalog files of the current locale from a directory; returns how many it loaded |
| `mclocale $locale` | Sets the current locale |

## Pitfalls

**A missing key is not an error.** `mc` returns the key itself. That makes a forgotten translation easy to spot on screen, and impossible to catch with `try`.

**Keys are identifiers, not the text.** Use dotted names (`items.count`) rather than the English sentence, so changing a wording does not change the key.

**`mc` is evaluated when it is called.** A widget built before the catalog is loaded shows keys, and changing the locale later does not update texts that were already built. Load the catalog first.

**A language does not borrow keys from another.** If a key is missing in the loaded catalogs, you get the key, not the text of some default language, unless that catalog is loaded too. A new language has to be complete.

**Values go through `format`.** Write `%s` or `%d` in the text and pass the values to `mc`: `mc items.count 3`.

**The current locale comes from the system** until you call `mclocale`. If there is no catalog for it, `mcload` loads nothing and returns 0.

## Official documentation

- [msgcat](https://www.tcl-lang.org/man/tcl/TclCmd/msgcat.htm)
