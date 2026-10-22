migrations register 1 {
    db eval {
        CREATE TABLE IF NOT EXISTS products (
            id      INTEGER PRIMARY KEY,
            code    TEXT    UNIQUE  NOT NULL,
            name    TEXT    UNIQUE  NOT NULL,
            notes   TEXT            NOT NULL DEFAULT ''
        ) STRICT
    }
}
