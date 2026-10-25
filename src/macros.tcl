snit::macro propagate {option "to" components} {
    option $option -configuremethod Propagate$option

    set body {}
    lappend body "set options($option) \$value"

    foreach comp $components {
        lappend body "\$$comp configure $option \$value"
    }

    method Propagate$option {option value} [join $body "\n"]
}
