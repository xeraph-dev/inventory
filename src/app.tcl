snit::widget app {
    hulltype ttk::frame

    component tabs

    delegate method * to hull
    delegate option * to hull

    constructor args {
        install tabs using ttk::notebook $win.tabs
        $tabs add [products-panel $tabs.products] -text [mc products]

        pack $tabs -fill both -expand yes

        $self configurelist $args
    }
}
