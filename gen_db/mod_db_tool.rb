require 'sequel'
require_relative '../models/user.rb'

#DB.alter_table :users do
#  add_column :first_time_login, String
#end
to_delete = [179103045,
            315441344,
            601029286,
            979376292]

to_delete.each do |id|
  user = User.first(id: id)
  user.delete
  puts "Deleted #{id}"
end

#user.save
#user.delete
#user.profile_pic = ''
#user.save

#User.where(acc_type: nil).delete