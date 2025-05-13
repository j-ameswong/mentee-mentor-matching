require_relative '../models/user'
require_relative '../db/db'

TicketType.create(:name=>'withdrawal', :desc_brief=>"Withdraw from match", :description=>'User has requested to withdraw from a match')
TicketType.create(:name=>'report', :desc_brief=>"Report user", :description=>'A user has made a report against another user')
TicketType.create(:name=>'edit_profile', :desc_brief=>"Edit restricted profile", :description=>'A user has made a request to edit a protected field in their profile')
TicketType.create(:name=>'deletion', :desc_brief=>"Request Account Deletion", :description=>'A user has made an account deletion request')
TicketType.create(:name=>'na', :desc_brief=>"Other", :description=>'A user has made a custom support ticket')

