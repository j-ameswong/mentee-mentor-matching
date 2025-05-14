require 'sequel'
require_relative '../models/user.rb'
require_relative '../db/db.rb'

messages = [
  { message_type: 'account_deleted', message_description: 'Your account has been deleted by an admin' },
  { message_type: 'account_flagged', message_description: 'Your account has been flagged by an admin due to misconduct' },
  { message_type: 'match_success', message_description: 'You have successfully been matched' },
  { message_type: 'match_completed', message_description: 'Your match has been completed' },
  { message_type: 'match_reassigned', message_description: 'Your match has been reassigned due to extenuating circumstances' },
  { message_type: 'match_pending', message_description: 'You have no matches yet' },
  { message_type: 'match_declined', message_description: 'You have been declined by the mentor you have applied for' },
  { message_type: 'match_cancelled', message_description: 'Your match with your mentor has been cancelled' },
  { message_type: 'badge_applied', message_description: 'You have received the Experienced Mentor badge' },
  { message_type: 'waitlisted', message_description: 'You have been waitlisted for a potential match' },
  { message_type: 'match_pending', message_description: 'You have received a new mentee application' },
  { message_type: 'report', message_description: 'Your account has been reported for misconduct' }
]

messages.each do |msg|
  Message.find_or_create(message_type: msg[:message_type]) do |m|
    m.message_description = msg[:message_description]
  end
end