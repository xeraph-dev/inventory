# Communication

How widgets talk to each other, and how screens stay in sync with the database.

## Events go up, methods go down

A widget never calls its parent. When something happens that the outside
should know about (a row was selected, a form was saved), the widget generates
a **virtual event** on itself (see [Virtual events](../tcl-notes/tk/events.md)). The parent, which created the child and knows
who else is involved, binds to that event and decides what to do, usually by
calling a method of another child.

```tcl
# In the child: announce what happened, with one value as data
event generate $win <<ItemSelected>> -data $id

# In the parent: react by calling a method of a sibling
bind $table <<ItemSelected>> [list $form edit %d]
```

- Virtual events need no declaration: pick a name like `<<Subject Action>>` and use it.
- `-data` carries one string, which the binding reads with `%d`. Use an empty string when there is nothing to carry, and handle it on the receiving side.
- **Bind on the widget that generates the event**, not on an ancestor: a virtual event is delivered to the widget it was generated on, and bindings on its parent frame do not see it.
- Percent codes are replaced in the script text, so keep the binding a single method call built with `list`.

### Refusing a change

When a form has unsaved changes and the user selects another row, the form asks
for confirmation. If the user refuses, the form generates an event carrying the
id it is still editing, and the parent selects that row again in the table:

```tcl
bind $form <<EditRejected>> [list $table select %d]
```

Selecting from code makes the table generate its own selection event
(see [ttk::treeview](../tcl-notes/tk/ttk-treeview.md#pitfalls)), which reaches
the form again. Make the receiver **idempotent**: if the form is already
editing that id, it does nothing, and the loop ends.

## Keeping views in sync

A table must show the current rows even when another panel changed them (a
purchase changes stock, a sale changes it back). Widgets do not know who else
is listening, so they share a **revision counter per table** instead of
sending events to each other:

- The root widget owns an array with one counter per table and passes its name down to the panels through an option.
- Whoever writes to a table increments its counter after a successful write.
- Whoever shows a table watches its counter and refreshes when it changes.

```tcl
# Root widget: the counters, and passing them on
variable revisions -array {suppliers 0}
install panel using suppliers-panel $tabs.suppliers -revisions [myvar revisions]

# Writer (a form): reach the array by name with upvar, then bump it
upvar $options(-revisions) revisions
db eval {INSERT INTO suppliers (name) VALUES (:name)}
incr revisions(suppliers)

# Reader (a table): refresh on every write to the counter
trace add variable $options(-revisions)(suppliers) write [mymethod refresh]
```

How the pieces work: [upvar](../tcl-notes/tcl/upvar.md) for reaching the array by name and [trace](../tcl-notes/tcl/trace.md) for reacting to writes.

Details that matter:

- The trace only fires on **changes**: also call `refresh` once when the widget is built.
- A trace calls its command with three extra arguments, so the refresh method must accept and ignore them (`method refresh args {...}`).
- Remove the trace in the widget's destructor, or it keeps pointing at a destroyed widget. See [Destructor](../tcl-notes/tcl/snit.md#destructor).
- A panel hands the option on to the children that need it. The option needs a handler that stores the value and forwards it, so a macro that generates it avoids repeating the code. See [Options with a handler](../tcl-notes/tcl/snit.md#options-with-a-handler) and [Macros](../tcl-notes/tcl/snit.md#macros).
- `myvar` gives a variable name that works from any scope, which is why it is what gets passed down. See [Variables](../tcl-notes/tcl/snit.md#variables).
