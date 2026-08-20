DROP TABLE IF EXISTS tickets CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS booking_items CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS seats CASCADE;
DROP TABLE IF EXISTS events CASCADE;
DROP TABLE IF EXISTS venues CASCADE;
DROP TABLE IF EXISTS users CASCADE;


CREATE TABLE users
(
    user_id       SERIAL PRIMARY KEY,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    password_hash VARCHAR(100) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    role          VARCHAR(20)  NOT NULL DEFAULT 'CLIENT'
        CHECK (role IN ('CLIENT', 'ORGANIZER', 'ADMIN')),
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE venues
(
    venue_id SERIAL PRIMARY KEY,
    name     VARCHAR(100) NOT NULL UNIQUE,
    address  VARCHAR(200) NOT NULL,
    capacity INT          NOT NULL CHECK (capacity > 0)
);


CREATE TABLE events
(
    event_id        SERIAL PRIMARY KEY,
    title           VARCHAR(100) NOT NULL,
    description     TEXT         NOT NULL,
    start_date_time TIMESTAMP    NOT NULL,
    end_date_time   TIMESTAMP    NOT NULL,

    venue_id        INT          NOT NULL REFERENCES venues (venue_id),

    status          VARCHAR(20)  NOT NULL DEFAULT 'DRAFT'
        CHECK (status IN ('DRAFT', 'PUBLISHED', 'CANCELLED', 'FINISHED')),

    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (end_date_time > start_date_time)
);


CREATE TABLE seats
(
    seat_id     SERIAL PRIMARY KEY,
    venue_id    INT NOT NULL REFERENCES venues (venue_id),
    row_number  INT NOT NULL,
    seat_number INT NOT NULL,
    price       INT NOT NULL CHECK (price >= 0),

    UNIQUE (venue_id, row_number, seat_number)
);


CREATE TABLE bookings
(
    booking_id  SERIAL PRIMARY KEY,

    user_id     INT         NOT NULL REFERENCES users (user_id),
    event_id    INT         NOT NULL REFERENCES events (event_id),

    status      VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (status IN ('PENDING', 'CONFIRMED', 'CANCELLED', 'EXPIRED')),

    total_price INT         NOT NULL CHECK (total_price >= 0),

    created_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at  TIMESTAMP   NOT NULL
);


CREATE TABLE booking_items
(
    booking_item_id SERIAL PRIMARY KEY,

    booking_id      INT NOT NULL REFERENCES bookings (booking_id) ON DELETE CASCADE,
    seat_id         INT NOT NULL REFERENCES seats (seat_id),

    price           INT NOT NULL CHECK (price >= 0),

    UNIQUE (booking_id, seat_id)
);


CREATE TABLE payments
(
    payment_id SERIAL PRIMARY KEY,

    booking_id INT         NOT NULL REFERENCES bookings (booking_id),

    amount     INT         NOT NULL CHECK (amount >= 0),

    status     VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED')),

    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE tickets
(
    ticket_id   SERIAL PRIMARY KEY,

    booking_id  INT         NOT NULL REFERENCES bookings (booking_id),

    seat_id     INT         NOT NULL REFERENCES seats (seat_id),

    ticket_code VARCHAR(50) NOT NULL UNIQUE,

    issued_at   TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);