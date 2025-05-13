require_relative '../models/user'
require_relative '../db/db'

GlobalVariable.where(:id != nil).each { |v| v.delete }

max_matches = GlobalVariable.new
max_matches.name = "GLOBAL_MAX_MATCHES"
max_matches.value = 3
max_matches.description = "Global number of mentees a mentor can take on"
max_matches.save

end_date = GlobalVariable.new
end_date.name = "SEMESTER_END_DATE"
end_date.value = DateTime.new(2025,5,24).to_i
end_date.description = "Semester end date, also date mentorship ends"
end_date.save





