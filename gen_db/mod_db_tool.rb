require 'sequel'
require_relative '../models/user.rb'
require_relative '../db/db.rb'

DB.transaction do
  unless DB.schema(:authentication).map { |col| col[0] }.include?(:flagged)
    puts "flagged column added to the authentication table"
    DB.alter_table :authentication do
      add_column :flagged, TrueClass, default: false
    end
  end
  
  unless DB.schema(:authentication).map { |col| col[0] }.include?(:flag_reasoning)
    puts "flag_reasoning column added to the authentication table"
    DB.alter_table :authentication do
      add_column :flag_reasoning, String, text: true
    end
  end
  
  unless DB.table_exists?(:flagged_accounts)
    puts "Creating flagged_accounts table"
    DB.create_table :flagged_accounts do
      primary_key :id
      String :user_id
      String :flag_reasoning, text: true
      DateTime :flagged_at
      
      index :user_id
    end
  end
end
