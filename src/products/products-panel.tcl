snit::widget products-panel {
    hulltype ttk::frame

    delegate method * to hull
    delegate option * to hull

    constructor args {
        $self configurelist $args
    }
}
