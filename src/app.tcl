snit::widget app {
    hulltype ttk::frame

    component tabs
    component products_tab

    delegate method * to hull
    delegate option * to hull

    variable revisions -array {
        products 0
    }

    constructor args {
        install tabs using ttk::notebook $win.tabs
        install products_tab using products-panel $tabs.products -revisions [myvar revisions]

        $tabs add $products_tab -text [mc products]

        pack $tabs -fill both -expand yes

        $self configurelist $args
    }
}
