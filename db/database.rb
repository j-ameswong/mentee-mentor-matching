# config/database.rb
require 'sequel'

DB = Sequel.connect('sqlite://db/db_test.sqlite3')

Sequel.extension :migration
Sequel::Migrator.run(DB, 'db/migrations') if Dir.exist?('db/migrations')