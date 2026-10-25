snit::widget products-panel {
    hulltype ttk::frame

    component table
    component form

    propagate -revisions to {table form}

    delegate method * to hull
    delegate option * to hull

    constructor args {
        install table using products-table $win.table
        install form using product-form $win.form -padding 4

        pack $table -side left -fill both -expand yes
        pack $form -side left -fill y

        $self configurelist $args

        bind $table <<ProductSelected>> [list $form edit %d]
        bind $form <<ProductFormCancel>> [list $table unselect]
        bind $form <<ProductEditRejected>> [list $table select %d]
    }
}
