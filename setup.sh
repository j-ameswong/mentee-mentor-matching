#!/bin/bash

# gem install pkg-config
bundle install

rm ./db/db_test.sqlite3

sqlite3 ./db/db_test.sqlite3 < ./db/schema.sql
echo "Schema successfully applied to DB!"

ruby ./gen_db/gen_db.rb
echo "Database populated with initial users!"