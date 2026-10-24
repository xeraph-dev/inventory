snit::widget products-table {
    hulltype ttk::frame

    component tree
    component scroll

    delegate method * to hull
    delegate option * to hull

    constructor args {
        install tree using ttk::treeview $win.tree -show headings -columns {code name notes}
        install scroll using ttk::scrollbar $win.scroll -orient vertical -command [list $tree yview]
        $tree configure -yscrollcommand [list $scroll set]
        $tree heading code -text [mc products.code]
        $tree heading name -text [mc products.name]
        $tree heading notes -text [mc products.notes]
        $tree column code -minwidth 80 -width 80

        pack $tree -side left -fill both -expand yes
        pack $scroll -side right -fill y

        $self configurelist $args
    }
}
