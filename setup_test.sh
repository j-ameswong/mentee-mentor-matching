#!/bin/bash

# gem install pkg-config
bundle install

echo "Setting up test db..."
sleep 1

rm ./db/db_test.sqlite3

sqlite3 ./db/db_test.sqlite3 < ./db/schema.sql
echo "Schema successfully applied to DB!"

ruby ./gen_db/pre_test.rb

ruby ./gen_db/csv_to_table_expertises.rb
ruby ./gen_db/csv_to_table_languages.rb
ruby ./gen_db/csv_to_table_nationalities.rb
ruby ./gen_db/global_variable.rb
ruby ./gen_db/ticket_types.rb
ruby ./gen_db/gen_messages.rb

ruby ./setup_test.rb

echo "Database populated with initial users!"