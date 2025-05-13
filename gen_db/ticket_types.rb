require_relative '../models/user'
require_relative '../db/db'

TicketType.where(:id != nil).each { |v| v.delete }

TicketType.create(:name=>'withdrawal', :description=>'User has requested to withdraw from a match')
TicketType.create(:name=>'report', :description=>'A user has made a report against another user')
TicketType.create(:name=>'edit_profile', :description=>'A user has made a request to edit a protected field in their profile')
TicketType.create(:name=>'deletion', :description=>'A user has made an account deletion request')
TicketType.create(:name=>'na', :description=>'A user has made a custom support ticket')

