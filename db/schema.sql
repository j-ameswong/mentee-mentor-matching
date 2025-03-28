CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    university_email TEXT,
    date_of_birth TEXT,
    iv BLOB,
    salt BLOB,
    data_crypt BLOB,
    acc_type TEXT,
    profile_pic TEXT,
    languages TEXT,
    year_of_study TEXT,
    nationality TEXT,
    approved TEXT,
    username TEXT,
    first_time_login TEXT,
    description TEXT
);