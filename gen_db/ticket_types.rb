require_relative '../models/user'
require_relative '../db/db'

TicketType.create(:name=>'withdrawal', :desc_brief=>"Withdraw from match", :description=>'User has requested to withdraw from match')
TicketType.create(:name=>'report', :desc_brief=>"Report user", :description=>'User has made a report against another user')

