require_relative './db'
DB = Sequel.sqlite('./db.sqlite3')
DB.rename_table :user, :users

DB2 = Sequel.sqlite('./db.sqlite3')
DB2.rename_table :user, :users