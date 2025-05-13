require_relative '../db/db'
class UserLanguage < Sequel::Model
  plugin :timestamps, update_on_create: true

  many_to_one :user
  many_to_one :language, key: :id

  def self.create!(params)
    UserLanguage.where(user_id: params[:user_id]).each { |row| row.delete }
    params[:user_languages].each do |lang|
      lang = Language.first(id: lang)
      next unless lang

      user = UserLanguage.new
      user.user_id = params[:user_id]
      user.language_id = lang.id
      # puts user.inspect
      user.save
    end
  end
end