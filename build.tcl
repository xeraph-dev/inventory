const TCL [file join [file home] opt tcl 9.1]
const TCLLIB [file join [file home] opt tcllib 2.0 lib tcllib2.0]
const TKLIB [file join [file home] opt tklib 0.9 lib tklib0.9]
const PKGS {sqlite3.53.4}
const TCLLIB_PKGS {snit}
const TKLIB_PKGS {}

const APP_NAME inventory
const APP_ITEMS {lib migrations msgs res src main.tcl}

file delete -force dist
file mkdir dist

foreach {os arch exe} {
    osx arm64   wish9.1
    osx x86_64  wish9.1
    win x86_64  wish91s.exe
} {
    set tcl [file join $TCL $os $arch]
    set vfs [file join [file tempdir] $APP_NAME-$os-$arch.vfs]

    file delete -force $vfs
    file mkdir $vfs

    set mnt //zipfs:/base-$os-$arch
    zipfs mount [file join $tcl bin $exe] $mnt
    file copy [file join $mnt tcl_library] [file join $vfs tcl_library]
    file copy [file join $mnt tk_library] [file join $vfs tk_library]
    zipfs unmount $mnt

    foreach item $APP_ITEMS {
        if {[file exists $item]} {file copy $item [file join $vfs $item]}
    }

    file mkdir [file join $vfs lib tcllib]
    file mkdir [file join $vfs lib tklib]

    foreach pkg $PKGS        {file copy [file join $tcl lib $pkg] [file join $vfs lib $pkg]}
    foreach pkg $TCLLIB_PKGS {file copy [file join $TCLLIB $pkg] [file join $vfs lib tcllib $pkg]}
    foreach pkg $TKLIB_PKGS  {file copy [file join $TKLIB $pkg] [file join $vfs lib tklib $pkg]}

    switch -exact -- $os {
        osx {
            zipfs mkimg [file join dist $APP_NAME-$os-$arch] $vfs $vfs "" [file join $tcl bin $exe]
        }
        win {
            zipfs mkimg [file join dist $APP_NAME-$arch.exe] $vfs $vfs "" [file join $tcl bin $exe]
        }
    }

    file delete -force $vfs
}
