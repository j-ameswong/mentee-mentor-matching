-- Users
CREATE TABLE "users" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "username" TEXT,
    "email" TEXT,
    "role" TEXT, -- mentor, mentee, admin
    "created_at" DateTime,
    "updated_at" DateTime
);
CREATE INDEX "username_index" ON "users" ("username");

-- Authentication
CREATE TABLE "authentication" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "user_id" INTEGER,
    "iv" BLOB,
    "salt" BLOB,
    "data_crypt" BLOB,
    "approved" Boolean,
    "first_time_login" Boolean,
    "created_at" DateTime,
    "updated_at" DateTime,
    FOREIGN KEY ("user_id") REFERENCES "users" ("id")
);
CREATE INDEX "user_id_auth_index" ON "authentication" ("user_id");

-- Profiles
CREATE TABLE "profiles" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "user_id" INTEGER,
    "first_name" TEXT,
    "last_name" TEXT,
    "nationality_id" INTEGER,
    "date_of_birth" Date,
    "gender" TEXT,
    "profile_picture" TEXT,
    "bio_brief" TEXT,
    "bio_detailed" TEXT,
    "created_at" DateTime,
    "updated_at" DateTime,
    FOREIGN KEY ("user_id") REFERENCES "users" ("id"),
    FOREIGN KEY ("nationality_id") REFERENCES "nationalities" ("id")
);
CREATE INDEX "user_id_profile_index" ON "profiles" ("user_id");

-- All countries in the world
CREATE TABLE "nationalities" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "country_name" TEXT,
    "country_code" TEXT
);

-- Mentor Profiles
CREATE TABLE "mentor_profiles" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "user_id" INTEGER,
    "year_of_study" INTEGER,
    "num_matches" INTEGER, -- Cannot exceed max_matches
    "max_matches" INTEGER, -- This should only be set by mentor
    "badges" TEXT,
    "created_at" DateTime,
    "updated_at" DateTime,
    FOREIGN KEY ("user_id") REFERENCES "users" ("id")
);
CREATE INDEX "user_id_mentor_index" ON "mentor_profiles" ("user_id");

-- Mentee Profiles
CREATE TABLE "mentee_profiles" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "user_id" INTEGER,
    "availability" Boolean, -- SQLite uses INTEGER for boolean (0=false, 1=true)
    "created_at" DateTime,
    "updated_at" DateTime,
    FOREIGN KEY ("user_id") REFERENCES "users" ("id")
);
CREATE INDEX "user_id_mentee_index" ON "mentee_profiles" ("user_id");

-- Matches
CREATE TABLE "matches" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "mentor_id" INTEGER,
    "mentee_id" INTEGER,
    "status" TEXT, -- pending, matched, completed or cancelled
    "application_message" TEXT,
    "start_date" Date,
    "end_date" Date,
    "created_at" DateTime,
    "updated_at" DateTime,
    FOREIGN KEY ("mentor_id") REFERENCES "users" ("id"),
    FOREIGN KEY ("mentee_id") REFERENCES "users" ("id")
);
CREATE INDEX "mentor_mentee_index" ON "matches" ("mentor_id", "mentee_id");
CREATE INDEX "status_index" ON "matches" ("status");

-- User Expertises
CREATE TABLE "user_expertises" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "user_id" INTEGER,
    "expertise_id" INTEGER,
    "confidence_level" INTEGER, -- 1-10, level of perceived skill in the expertise
    "created_at" DateTime,
    "updated_at" DateTime,
    FOREIGN KEY ("user_id") REFERENCES "users" ("id"),
    FOREIGN KEY ("expertise_id") REFERENCES "expertises" ("id")
);
CREATE INDEX "user_id_user_expertises_index" ON "user_expertises" ("user_id");

-- List of all possible expertises
CREATE TABLE "expertises" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "category" TEXT,
    "skill" TEXT
);
CREATE INDEX "category_expertises_index" ON "expertises" ("category");

-- User Languages table
CREATE TABLE "user_languages" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "user_id" INTEGER,
    "language_id" INTEGER,
    "created_at" DateTime,
    "updated_at" DateTime,
    FOREIGN KEY ("user_id") REFERENCES "users" ("id"),
    FOREIGN KEY ("language_id") REFERENCES "languages" ("id")
);
CREATE INDEX "user_id_language_index" ON "user_languages" ("user_id");

-- List of all languages
CREATE TABLE "languages" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "language_name" TEXT,
    "native_name" TEXT,
    "language_code" TEXT
)