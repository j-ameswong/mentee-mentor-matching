require_relative '../db/db'

class GlobalVariable < Sequel::Model
  def self.MAX_MATCHES
    GlobalVariable.first(name: "GLOBAL_MAX_MATCHES").value
  end

  def self.END_DATE
    GlobalVariable.first(name: "SEMESTER_END_DATE").value
  end

  def GlobalVariable.set_max_matches(max_matches)
    max = GlobalVariable.first(name: "GLOBAL_MAX_MATCHES")
    max.value = max_matches
    max.save
  end

  def GlobalVariable.set_semester_end_date(end_date)
    ending_date = GlobalVariable.first(name: "SEMESTER_END_DATE")
    end_date = DateTime.strptime(end_date, "%Y-%m-%d").to_i
    ending_date.value = end_date
    ending_date.save
  end
end
