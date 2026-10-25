snit::widget product-form {
    hulltype ttk::frame

    component code_entry
    component name_entry
    component notes_entry
    component save_button
    component cancel_button
    component delete_button

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
        install delete_button using ttk::button $win.delete -text [mc common.delete] -command [mymethod delete] -state disabled

        grid $code_entry    -row 0 -columnspan 2 -pady {0 8}
        grid $name_entry    -row 1 -columnspan 2 -pady {0 8}
        grid $notes_entry   -row 2 -columnspan 2 -pady {0 8}
        grid $save_button   -row 3 -column 0     -pady {0 8} -padx {0 8}
        grid $cancel_button -row 3 -column 1     -pady {0 8}
        grid $delete_button -row 4 -column 1

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
                RETURNING id
            } {}
        }

        incr revisions(products)

        event generate $win <<ProductFormSave>> -data $id
        $self clear
    }

    method cancel {} {
        event generate $win <<ProductFormCancel>>
        $self clear
    }

    method delete {} {
        upvar $options(-revisions) revisions

        if {[tk_messageBox -type yesno -title [mc products.form.delete.title] -message [mc products.form.delete.message]] == no} {return}

        db eval {
            DELETE FROM products
            WHERE id = :id
        }

        incr revisions(products)

        event generate $win <<ProductDeleted>> -data $id
        $self clear
    }

    method clear {} {
        set id -1
        set code {}
        set name {}
        set notes {}
        $delete_button configure -state disabled
    }

    method edit {edit_id} {
        if {$edit_id == {} && $id == -1} {return}
        if {$edit_id == {} && $id != -1} {$self clear; return}
        db eval {SELECT code, name, notes FROM products WHERE id = :edit_id} {}
        set id $edit_id
        $delete_button configure -state normal
    }
}
