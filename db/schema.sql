CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    university_email TEXT,
    date_of_birth TEXT,
    iv TEXT,
    salt TEXT,
    data_crypt TEXT,
    acc_type TEXT
);