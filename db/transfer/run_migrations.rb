require 'sequel'

migrations_dir = File.expand_path('../migrations', __dir__)
database_dir = File.expand_path('../', __dir__)

database = Sequel.connect("sqlite://#{database_dir}/db_test.sqlite3")

Sequel.extension :migration
Sequel::Migrator.run(database, "#{migrations_dir}") if Dir.exist?("#{migrations_dir}")
