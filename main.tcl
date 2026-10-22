const APP_DIR [file dirname [info script]]
const APP_NAME inventory

foreach dir {{} tcllib tklib} {lappend auto_path [file join $APP_DIR lib $dir]}

package require snit
package require sqlite3
package require msgcat

namespace import msgcat::*

proc source-files {dir} {
    foreach file [glob -directory $dir -types f *.tcl]  {source $file}
    foreach dir  [glob -directory $dir -types d *]      {source-files $dir}
}

foreach dir {src migrations} {source-files [file join $APP_DIR $dir]}

const DATA_DIR [get-data-dir]
file mkdir $DATA_DIR

sqlite3 db [file join $DATA_DIR $APP_NAME.db]

db eval {PRAGMA foreign_keys = ON}
db eval {PRAGMA journal_mode = WAL}
db eval {PRAGMA synchronous = NORMAL}

mcload [file join $APP_DIR msgs]
migrations run_pending

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
