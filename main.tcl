const APP_DIR [file dirname [info script]]
const APP_NAME inventory
const DEFAULT_LOCALE es

foreach dir {{} tcllib tklib} {lappend auto_path [file join $APP_DIR lib $dir]}

package require snit
package require sqlite3
package require msgcat

namespace import msgcat::*

proc source-files {dir} {
    foreach file [lsort [glob -nocomplain -directory $dir -types f *.tcl]]  {source $file}
    foreach sub  [lsort [glob -nocomplain -directory $dir -types d *]]      {source-files $sub}
}

foreach dir {src migrations} {source-files [file join $APP_DIR $dir]}

const DATA_DIR [get_data_dir]
file mkdir $DATA_DIR

sqlite3 db [file join $DATA_DIR $APP_NAME.db]

db eval {PRAGMA foreign_keys = ON}
db eval {PRAGMA journal_mode = WAL}
db eval {PRAGMA synchronous = FULL}

migrations run_pending

if {![mcload [file join $APP_DIR msgs]]} {
    mclocale $DEFAULT_LOCALE
    mcload [file join $APP_DIR msgs]
}

wm title . [mc window.title]

image create photo app-icon -file [file join $APP_DIR res app-icon.png]
wm iconphoto . app-icon

pack [app .app] -expand yes -fill both

update idletasks
wm minsize . [winfo reqwidth .] [winfo reqheight .]

wm protocol . WM_DELETE_WINDOW {
    db close
    destroy .
}
