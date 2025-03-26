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
    profile_pic BLOB
);