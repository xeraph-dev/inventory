snit::widget product-form {
    hulltype ttk::frame

    component code_entry
    component name_entry
    component notes_entry
    component save_button
    component cancel_button

    option -revisions

    delegate method * to hull
    delegate option * to hull

    variable id -1

    variable code {}
    variable name {}
    variable notes {}

    constructor args {
        install code_entry using labelentry $win.code -label [mc products.code] -textvariable [myvar code]
        install name_entry using labelentry $win.name -label [mc products.name] -textvariable [myvar name]
        install notes_entry using labelentry $win.notes -label [mc products.notes] -textvariable [myvar notes]
        install save_button using ttk::button $win.save -text [mc common.save] -command [mymethod save]
        install cancel_button using ttk::button $win.cancel -text [mc common.cancel] -command [mymethod cancel]

        grid $code_entry    -row 0 -columnspan 2 -pady {0 8}
        grid $name_entry    -row 1 -columnspan 2 -pady {0 8}
        grid $notes_entry   -row 2 -columnspan 2 -pady {0 8}
        grid $save_button   -row 3 -column 0     -padx {0 8}
        grid $cancel_button -row 3 -column 1

        $self configurelist $args
    }

    method save {} {
        upvar $options(-revisions) revisions

        if {$id == -1} {
            db eval {
                INSERT INTO products (code, name, notes)
                VALUES (:code, :name, :notes)
            }
        } else {
            db eval {
                UPDATE products
                SET code = :code,
                    name = :name,
                    notes = :notes
                WHERE id = :id
            }
        }

        incr revisions(products)

        $self clear
        event generate $win <<ProductFormSave>>
    }

    method cancel {} {
        $self clear
        event generate $win <<ProductFormCancel>>
    }

    method clear {} {
        set id -1
        set code {}
        set name {}
        set notes {}
    }

    method edit {edit_id} {
        db eval {SELECT code, name, notes FROM products WHERE id = :edit_id} {}
        set id $edit_id
    }
}
