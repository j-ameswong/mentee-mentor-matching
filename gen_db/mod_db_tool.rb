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

# User.where(role: nil).delete
# User.where(role: nil).delete
# User.where(role: nil).delete
# User.where(role: nil).delete

# -- User messages table
# CREATE TABLE "user_messages" (
#     "id" INTEGER PRIMARY KEY AUTOINCREMENT,
#     "sent_by" TEXT
#     "recieved_by" TEXT,
#     "message_id" INTEGER,
#     "read_status" Boolean,
#     "created_at" DateTime,
#     FOREIGN KEY ("message_id") REFERENCES "messages" ("id"),
# );
# CREATE INDEX "user_id_message_index" ON "user_messages" ("message_id");

# -- List of all messages
# CREATE TABLE "messages" (
#     "id" INTEGER PRIMARY KEY AUTOINCREMENT,
#     "message_type" TEXT,
#     "message_description" TEXT,
# );

# DB.create_table? :user_messages do
#   primary_key :id
#   String :sent_by
#   String :recieved_by
#   foreign_key :message_id, :messages
#   Boolean :read_status
#   DateTime :created_at
# end

# DB.create_table? :messages do
#   primary_key :id
#   String :message_type
#   String :message_description
# end

# messages = [
#   { message_type: 'account_deleted', message_description: 'Your account has been deleted by an admin' },
#   { message_type: 'account_flagged', message_description: 'Your account has been flagged by an admin due to misconduct' },
#   { message_type: 'match_success', message_description: 'You have successfully been matched' },
#   { message_type: 'match_completed', message_description: 'Your match has been completed' },
#   { message_type: 'match_reassigned', message_description: 'Your match has been reassigned due to extenuating circumstances' },
#   { message_type: 'match_pending', message_description: 'You have no matches yet' },
#   { message_type: 'match_declined', message_description: 'You have been declined by the mentor you have applied for' },
#   { message_type: 'match_cancelled', message_description: 'Your match with your mentor has been cancelled' },
#   { message_type: 'badge_applied', message_description: 'You have received the Experienced Mentor badge' },
#   { message_type: 'waitlisted', message_description: 'You have been waitlisted for a potential match' },
#   { message_type: 'report', message_description: 'Your account has been reported for misconduct' }
# ]

# messages.each do |msg|
#   Message.find_or_create(message_type: msg[:message_type]) do |m|
#     m.message_description = msg[:message_description]
#   end
# end

DB.alter_table :user_messages do
  rename_column :recieved_by, :received_by
end
