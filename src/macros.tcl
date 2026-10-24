snit::macro propagate {option "to" components} {
    option $option -configuremethod Propagate$option

    set body {}

    foreach comp $components {
        lappend body "\$$comp configure $option \$value"
    }

    method Propagate$option {option value} [join $body "\n"]
}
