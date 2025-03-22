-- Users
CREATE TABLE "users" (
                         "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                         "username" TEXT,
                         "email" TEXT,
                         "role" TEXT, -- mentor, mentee, admin
                         "created_at" TEXT,
                         "updated_at" TEXT
);
CREATE INDEX "username_index" ON "users" ("username");

-- Authentication
CREATE TABLE "authentication" (
                                  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                                  "user_id" INTEGER,
                                  "iv" BLOB,
                                  "salt" BLOB,
                                  "data_crypt" BLOB,
                                  "created_at" TEXT,
                                  "updated_at" TEXT,
                                  FOREIGN KEY ("user_id") REFERENCES "users" ("id")
);
CREATE INDEX "user_id_auth_index" ON "authentication" ("user_id");

-- Profiles
CREATE TABLE "profiles" (
                            "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                            "user_id" INTEGER,
                            "first_name" TEXT,
                            "last_name" TEXT,
                            "nationality" TEXT,
                            "date_of_birth" TEXT,
                            "profile_picture" TEXT,
                            "bio_brief" TEXT,
                            "bio_detailed" TEXT,
                            "created_at" TEXT,
                            "updated_at" TEXT,
                            FOREIGN KEY ("user_id") REFERENCES "users" ("id")
);
CREATE INDEX "user_id_profile_index" ON "profiles" ("user_id");

-- Mentor Profiles
CREATE TABLE "mentor_profiles" (
                                   "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                                   "user_id" INTEGER,
                                   "year_of_study" INTEGER,
                                   "num_matches" INTEGER, -- Cannot exceed max_matches
                                   "max_matches" INTEGER, -- This should only be set by mentor
                                   "badges" TEXT,
                                   "created_at" TEXT,
                                   "updated_at" TEXT,
                                   FOREIGN KEY ("user_id") REFERENCES "users" ("id")
);
CREATE INDEX "user_id_mentor_index" ON "mentor_profiles" ("user_id");

-- Mentee Profiles
CREATE TABLE "mentee_profiles" (
                                   "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                                   "user_id" INTEGER,
                                   "availability" INTEGER, -- SQLite uses INTEGER for boolean (0=false, 1=true)
                                   "created_at" TEXT,
                                   "updated_at" TEXT,
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
                           "start_date" TEXT,
                           "end_date" TEXT,
                           "created_at" TEXT,
                           "updated_at" TEXT,
                           FOREIGN KEY ("mentor_id") REFERENCES "users" ("id"),
                           FOREIGN KEY ("mentee_id") REFERENCES "users" ("id")
);
CREATE INDEX "mentor_mentee_index" ON "matches" ("mentor_id", "mentee_id");
CREATE INDEX "status_index" ON "matches" ("status");

-- User Expertises
CREATE TABLE "user_expertises" (
                                   "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                                   "user_id" INTEGER,
                                   "skill" TEXT,
                                   "created_at" TEXT,
                                   "updated_at" TEXT,
                                   FOREIGN KEY ("user_id") REFERENCES "users" ("id")
);
CREATE INDEX "skill_index" ON "user_expertises" ("skill");

-- User Languages table
CREATE TABLE "user_languages" (
                                  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                                  "user_id" INTEGER,
                                  "language" TEXT,
                                  "created_at" TEXT,
                                  "updated_at" TEXT,
                                  FOREIGN KEY ("user_id") REFERENCES "users" ("id")
);
CREATE INDEX "user_id_language_index" ON "user_languages" ("user_id");