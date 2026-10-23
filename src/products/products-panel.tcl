snit::widget products-panel {
    hulltype ttk::frame

    component table

    delegate method * to hull
    delegate option * to hull

    constructor args {
        install table using products-table $win.table

        pack $table -fill both -expand yes

        $self configurelist $args
    }
}
