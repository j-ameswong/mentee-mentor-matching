# Original schema, saved for documentation purposes. Do not use. Very bad.

Sequel.migration do
  change do
    create_table :users do
      primary_key :id
      String :first_name
      String :last_name
      String :university_email
      String :date_of_birth
      BLOB :iv
      BLOB :salt
      BLOB :data_crypt
      String :acc_type
      String :profile_pic
      String :languages
      String :year_of_study
      String :nationality
      String :approved
      String :username
      String :first_time_login
      String :description
    end
  end
end