#!/bin/bash

# gem install pkg-config
bundle install

rm ./db/db_test.sqlite3

sqlite3 ./db/db_test.sqlite3 < ./db/schema.sql
echo "Schema successfully applied to DB!"

ruby ./gen_db/csv_to_table_expertises.rb
ruby ./gen_db/csv_to_table_languages.rb
ruby ./gen_db/csv_to_table_nationalities.rb
ruby ./gen_db/global_variable.rb
ruby ./gen_db/ticket_types.rb

ruby setup.rb

echo "Database populated with initial users!"