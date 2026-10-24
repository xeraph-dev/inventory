snit::widget products-table {
    hulltype ttk::frame

    component tree
    component scroll

    option -revisions -configuremethod ConfigureRevisionsOption

    delegate method * to hull
    delegate option * to hull

    constructor args {
        install tree using ttk::treeview $win.tree -show headings -columns {code name notes} -selectmode browse
        install scroll using ttk::scrollbar $win.scroll -orient vertical -command [list $tree yview]
        $tree configure -yscrollcommand [list $scroll set]
        $tree heading code -text [mc products.code]
        $tree heading name -text [mc products.name]
        $tree heading notes -text [mc products.notes]
        $tree column code -minwidth 80 -width 80

        pack $tree -side left -fill both -expand yes
        pack $scroll -side right -fill y

        $self configurelist $args

        $self refresh
    }

    destructor {
        try {trace remove variable $options(-revisions)(products) write [mymethod refresh]}
    }

    method ConfigureRevisionsOption {option value} {
        set options($option) $value
        trace add variable $options(-revisions)(products) write [mymethod refresh]
    }

    method refresh args {
        $tree delete [$tree children {}]
        db eval {SELECT id, code, name, notes FROM products ORDER BY code} {
            $tree insert {} end -id $id -values [list $code $name $notes]
        }
    }
}
