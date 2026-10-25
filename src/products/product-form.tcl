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

    variable loaded {{} {} {}}

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

    method dirty {} {
        expr {[list $code $name $notes] ne $loaded}
    }

    method save {} {
        upvar $options(-revisions) revisions

        try {
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
        } on error {msg opts} {
            if {[regexp {^UNIQUE constraint failed: products\.(\w+)} $msg -> column]} {
                set key products.form.duplicate.$column
            } elseif {[regexp {^CHECK constraint failed: products_(\w+)_not_empty} $msg -> column]} {
                set key products.form.empty.$column
            } else {
                return -options $opts $msg
            }
            tk_messageBox -type ok -icon error -title [mc common.error] -message [mc $key]
            return
        }

        incr revisions(products)

        event generate $win <<ProductFormSave>> -data [db last_insert_rowid]
        $self clear
    }

    method cancel {} {
        event generate $win <<ProductFormCancel>>
        $self clear
    }

    method delete {} {
        upvar $options(-revisions) revisions

        set answer [tk_messageBox -type yesno -icon warning -default no \
            -title [mc products.form.delete.title] \
            -message [mc products.form.delete.message $name]]
        if {$answer eq no} {return}

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
        set loaded [list $code $name $notes]
        $delete_button configure -state disabled
    }

    method edit {edit_id} {
        if {$edit_id eq ""} {
            if {$id != -1} {$self clear}
            return
        }

        if {$edit_id == $id} {return}

        if {[$self dirty]} {
            set answer [tk_messageBox -type yesno -icon warning -default no \
                -title [mc products.form.discard.title] \
                -message [mc products.form.discard.message]]
            if {$answer eq no} {
                event generate $win <<ProductEditRejected>> -data [expr {$id == -1 ? "" : $id}]
                return
            }
        }

        db eval {SELECT code, name, notes FROM products WHERE id = :edit_id} {}
        set id $edit_id
        set loaded [list $code $name $notes]
        $delete_button configure -state normal
    }
}
