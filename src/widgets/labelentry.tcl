snit::widgetadaptor labelentry {
    component entry

    delegate option -label to hull as -text

    delegate method * to entry
    delegate option * to entry

    constructor args {
        installhull using ttk::labelframe

        install entry using ttk::entry $win.entry

        pack $entry -fill both -expand yes

        $self configurelist $args
    }
}
