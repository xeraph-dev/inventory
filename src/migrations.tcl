namespace eval migrations {
    namespace export register run_pending
    namespace ensemble create

    variable steps [dict create]

    proc register {version script} {
        variable steps
        dict set steps $version $script
    }

    proc create_table {} {
        db eval {
            CREATE TABLE IF NOT EXISTS schema_migrations (
                version INTEGER PRIMARY KEY AUTOINCREMENT,
                applied_at INTEGER NOT NULL
            ) STRICT
        }
    }

    proc current_version {} {
        db onecolumn {SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 1}
    }

    proc run_pending {} {
        variable steps
        if {[dict size $steps] == 0} return

        create_table
        set current [current_version]

        foreach version [lsort -integer [dict keys $steps]] {
            if {$version <= $current} continue
            set script [dict get $steps $version]

            db transaction {
                uplevel $script
                set now [clock seconds]
                db eval {
                    INSERT INTO schema_migrations (version, applied_at)
                    VALUES (:version, :now)
                }
            }
        }
    }
}
