snit::widget product-form {
    hulltype ttk::frame

    component code_entry
    component name_entry
    component notes_entry
    component save_button

    option -revisions

    delegate method * to hull
    delegate option * to hull

    variable code {}
    variable name {}
    variable notes {}

    constructor args {
        install code_entry using labelentry $win.code -label [mc products.code] -textvariable [myvar code]
        install name_entry using labelentry $win.name -label [mc products.name] -textvariable [myvar name]
        install notes_entry using labelentry $win.notes -label [mc products.notes] -textvariable [myvar notes]
        install save_button using ttk::button $win.save -text [mc common.save] -command [mymethod save]

        pack $code_entry $name_entry $notes_entry -pady {0 8} -fill x
        pack $save_button -fill x

        $self configurelist $args
    }

    method save {} {
        upvar $options(-revisions) revisions

        db eval {
            INSERT INTO products (code, name, notes)
            VALUES (:code, :name, :notes)
        }


        incr revisions(products)

        $self clear
    }

    method clear {} {
        set code {}
        set name {}
        set notes {}
    }
}
