snit::widget labelentry {
    hulltype ttk::labelframe

    component entry

    option -takefocus 0

    delegate option -label to hull as -text
    delegate method * to entry
    delegate option * to entry

    constructor args {
        install entry using ttk::entry $win.entry
        pack $entry -fill both -expand yes
        $self configurelist $args
    }
}
