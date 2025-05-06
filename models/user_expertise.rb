require_relative '../db/db'

class UserExpertise < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :user
  many_to_one :expertise, key: :id

  def self.create!(params)
    UserExpertise.where(user_id: params[:user_id]).each { |row| row.delete }
    params[:user_expertises].each do |expertise|
      expertise = Expertise.first(id: expertise)
      next unless expertise

      new_entry = UserExpertise.new
      new_entry.user_id = params[:user_id]
      new_entry.expertise_id = expertise.id
      puts new_entry.inspect
      new_entry.save
    end
  end
end
