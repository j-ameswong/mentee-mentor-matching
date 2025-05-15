#!/bin/bash

# gem install pkg-config
bundle install

echo 'Setting up prod db...'
sleep 1

rm ./db/db.sqlite3

sqlite3 ./db/db.sqlite3 < ./db/schema.sql
echo "Schema successfully applied to DB!"

ruby ./gen_db/pre_prod.rb

ruby ./gen_db/csv_to_table_expertises.rb
ruby ./gen_db/csv_to_table_languages.rb
ruby ./gen_db/csv_to_table_nationalities.rb
ruby ./gen_db/global_variable.rb
ruby ./gen_db/ticket_types.rb
ruby ./gen_db/gen_messages.rb

ruby ./setup.rb

echo "Database populated with initial admin!"