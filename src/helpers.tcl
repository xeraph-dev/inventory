proc find_files {dir pattern} {
    set found [glob -nocomplain -directory $dir -types f $pattern]
    foreach sub [glob -nocomplain -directory $dir -types d *] {
        lappend found {*}[find_files $sub $pattern]
    }
    return $found
}

proc get_data_dir {} {
    switch -exact -- $::tcl_platform(os) {
        Darwin {file join [file home] Library {Application Support} $::APP_NAME}
        "Windows NT" {file join $::env(APPDATA) $::APP_NAME}
        default {error "get_data_dir: unknown platform: $::tcl_platform(os)"}
    }
}
