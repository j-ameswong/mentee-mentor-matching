# UniConnect - A Mentee-Mentor Matching Platform

A full-stack web application that facilitates mentor-mentee matching at the University of Sheffield. Built as a team project for COM1001 (Software Development) in the second semester of first year (2024-25).

Ruby/Sinatra | SQLite | RSpec/Capybara

## Overview

The platform connects first-year students (mentees) with experienced students (mentors) through a structured matching workflow. Administrators oversee the process, approving accounts, moderating behaviour, and managing system-wide settings. The application handles the full lifecycle of a mentoring relationship: from registration and profile creation, through matching and active mentorship, to completion or withdrawal.

## My Contributions

Lead developer and project architect, responsible for **250 of 471 total commits (53%)**, nearly three times the next highest contributor. My work spanned every layer of the application:

### Project Foundation & Database Architecture
- Scaffolded the initial project structure: first controllers, views, stylesheets, and landing page
- Designed and implemented the **complete database schema** (16 tables, fully relational) in SQLite
- Built the database generation system with CSV seed data (2,000+ entries) for testing
- Led a major **database migration/refactoring** from a flat structure to a normalised relational schema using Sequel migrations
- Created setup and initialisation scripts (`setup.sh`, `setup_test.sh`) for both production and test environments

### Authentication & User Management
- Built the **full authentication system**: login, signup, logout, session management
- Implemented AES-128-CBC password encryption with PBKDF2-HMAC-SHA1 key derivation (20,000 iterations)
- Created the admin signup and **account approval pipeline** (admin registers user -> approves -> user completes first-time login)
- Implemented role-based access control across three user tiers (Admin, Mentor, Mentee)
- Built the Terms & Conditions acceptance flow during registration

### Profile System
- Developed the **complete profile viewing and editing system** with fields for biography, nationality, languages, expertise, year of study, and profile pictures
- Implemented file upload handling for profile pictures (PNG/JPG, max 5MB)
- Added privacy features: **blurred profile pictures** and **hidden real names** before a match is established
- Enforced access control so unmatched users cannot view each other's full profiles

### Mentor-Mentee Matching Engine
- Built the **end-to-end matching system**: mentees browse and apply to mentors, mentors review and accept/decline applications
- Implemented match capacity enforcement (configurable max mentees per mentor)
- Created a **waitlist mechanism** for mentees when no mentors are available (7+ day threshold)
- Built match lifecycle management: pending -> active -> completed/cancelled/declined
- Added automatic match completion based on the semester end date
- Ensured availability status updates correctly when matches are formed or ended

### Support, Reporting & Moderation
- Created the **support ticketing system** with two ticket types: user reports and match withdrawal requests
- Built the admin support dashboard for reviewing and resolving tickets
- Implemented the **account flagging system** with flag reasoning, visual indicators, and unflag functionality
- Developed the match withdrawal workflow with duplicate prevention and partner notification
- Handled cascading user deletion: when an account is deleted, matched partners receive notification messages and orphaned data is cleaned up

### Data Models & ORM Layer
- Authored or was the primary contributor to **all 16 model classes**: User, Authentication, Profile, MentorProfile, MenteeProfile, Match, SupportTicket, TicketType, FlaggedAccount, GlobalVariable, UserExpertise, UserLanguage, Nationality, UserMessage, Expertise, Language
- Implemented model validations, relational associations, and business logic methods throughout

### Frontend & UX
- Built and maintained the main stylesheet (`styles.css`)
- Created JavaScript for dynamic UI: language/expertise tag selection, in-page application forms, matching filters
- Implemented notification indicators for unread messages
- Designed the mentee matching page layout with mentor cards and application flow

### Files Primarily Authored

Nearly every file in the `controllers/`, `models/`, and `views/` directories, plus all database infrastructure:

| Layer | Files |
|---|---|
| **Controllers** | `login.rb`, `signup.rb`, `signupAdmin.rb`, `account.rb`, `profile.rb`, `matches.rb`, `approvals.rb`, `support.rb`, `flagging.rb`, `logout.rb` |
| **Models** | `user.rb`, `authentication.rb`, `profile.rb`, `match.rb`, `support_ticket.rb`, `flagged_account.rb`, `global_variable.rb`, `user_expertise.rb`, `user_language.rb`, `nationality.rb`, `user_message.rb`, `ticket_type.rb` |
| **Views** | `login.erb`, `signup.erb`, `profile.erb`, `profileEdit.erb`, `menteeMatching.erb`, `mentorMatching.erb`, `mentorMatchingMatches.erb`, `support.erb`, `adminSupport.erb`, `approvals.erb`, `account.erb`, `changepassword.erb`, `terms.erb`, `index.erb`, `header.erb` |
| **Database** | `schema.sql`, `db.rb`, all migration files, `gen_db/` generation scripts, `setup.sh`, `setup_test.sh` |

## Tech Stack

| Component | Technology |
|---|---|
| Framework | Ruby with Sinatra |
| Database | SQLite 3 via Sequel ORM |
| Server | Puma |
| Templating | ERB (Embedded Ruby) |
| Testing | RSpec, Capybara, SimpleCov |
| Encryption | OpenSSL (AES-128-CBC) |

## Features

- **Three-tier role system** — Admins, Mentors, and Mentees with role-specific dashboards
- **Account approval workflow** — Admin review before users can access the platform
- **Rich user profiles** — Bio, nationality, languages, expertise areas, profile pictures
- **Matching engine** — Mentees apply to mentors; mentors accept/decline; configurable capacity limits
- **Waitlist system** — Mentees are waitlisted when no mentors are available
- **Messaging** — System-generated notifications for match events (accepted, declined, completed, cancelled)
- **Support tickets** — User reporting and match withdrawal requests with admin resolution
- **Account flagging** — Admin moderation tools with flag history and reasoning
- **Privacy controls** — Profile information hidden until a match is established
- **Semester end date** — Configurable deadline that automatically completes active matches

## Project Structure

```
├── app.rb                  # Application entry point
├── controllers/            # Route handlers (15 files)
├── models/                 # Data models and business logic (16 files)
├── views/                  # ERB templates (23 files)
│   └── common/             # Shared partials (header, footer)
├── helpers/                # Input validation utilities
├── public/                 # Static assets (CSS, JS, images)
├── db/                     # Database, schema, and migrations
├── gen_db/                 # Database generation and seed scripts
└── spec/                   # RSpec acceptance tests
```

## Setup

```bash
# Set up with test data (pre-populated database)
sh setup_test.sh

# Or set up for production (clean database, admin account only)
sh setup.sh

# Start the server
ruby app.rb
```

### Default Test Credentials

| Role | Username | Password |
|---|---|---|
| Admin | `admin` | `admin` |
| Mentee | `user` | `user` |
| Mentor | `user1` | `user1` |

## Running Tests

```bash
# Run acceptance tests
rspec

# View coverage report
pushd spec/_coverage/; python3 -m http.server 9999; popd
# Visit http://localhost:9999/#_AllFiles
```

## Database Schema

16 tables covering users, authentication, profiles (general/mentor/mentee), matches, expertise, languages, nationalities, messages, support tickets, flagged accounts, and global configuration.

Key relationships:
- Users have one authentication record, one profile, and optionally a mentor or mentee profile
- Matches link a mentor and mentee with status tracking and date management
- Users can have many expertises and languages (many-to-many via join tables)
- Support tickets reference both the sender and the target user
- System messages are templated and tracked with read/unread status
