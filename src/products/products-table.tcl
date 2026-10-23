snit::widget products-table {
    hulltype ttk::frame

    component tv
    component sb

    delegate method * to hull
    delegate option * to hull

    constructor args {
        install tv using ttk::treeview $win.tv -show headings -columns {code name notes} -selectmode browse
        install sb using ttk::scrollbar $win.sb -orient vertical -command [list $tv yview]
        $tv configure -yscrollcommand [list $sb set]
        $tv heading code -text [mc products.code]
        $tv heading name -text [mc products.name]
        $tv heading notes -text [mc products.notes]
        $tv column code -minwidth 80 -width 80

        pack $tv -side left -fill both -expand yes
        pack $sb -side right -fill y

        $self configurelist $args
    }
}
