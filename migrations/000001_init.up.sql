CREATE SCHEMA battle;

CREATE TABLE battle.users (
    id              SERIAL          PRIMARY KEY,
    version         BIGINT          NOT NULL    DEFAULT 1,
    full_name       VARCHAR(255)    NOT NULL    CHECK (char_length(full_name) BETWEEN 3 AND 255),
    phone_number    VARCHAR(20)     NOT NULL    CHECK (
        phone_number ~ '^\+?[1-9][0-9]*$'
        AND char_length(phone_number) BETWEEN 10 AND 20
    )
);

CREATE TABLE battle.tasks (
    id              SERIAL          PRIMARY KEY,
    version         BIGINT          NOT NULL    DEFAULT 1,
    title           VARCHAR(100)    NOT NULL    CHECK (char_length(title) BETWEEN 1 AND 100),
    description     VARCHAR(1000)               CHECK (description IS NULL OR char_length(description) BETWEEN 1 AND 1000),
    completed       BOOLEAN         NOT NULL    DEFAULT false,
    created_at      TIMESTAMPTZ     NOT NULL    DEFAULT now(),
    completed_at    TIMESTAMPTZ,
    author_id       INT             NOT NULL    REFERENCES battle.users(id),

    CHECK (
        (completed = false AND completed_at IS NULL)
        OR
        (completed = true AND completed_at IS NOT NULL AND completed_at >= created_at)
    )
);
