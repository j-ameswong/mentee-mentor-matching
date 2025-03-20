# db/migrations/001_create_initial_schema.rb
require_relative '../database'

Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :username
      String :email
      String :first_name
      String :last_name
      Date :date_of_birth
      String :role
      DateTime :created_at
      DateTime :updated_at

      index :username
    end

    create_table(:authentication) do
      primary_key :id
      foreign_key :user_id, :users
      BLOB :iv
      BLOB :salt
      BLOB :data_crypt
      DateTime :created_at
      DateTime :updated_at

      index :user_id
    end

    create_table(:profiles) do
      primary_key :id
      foreign_key :user_id, :users
      Text :bio
      Text :skills
      Text :interests
      String :profile_picture_url
      DateTime :created_at
      DateTime :updated_at

      index :user_id
    end

    create_table(:mentor_profiles) do
      primary_key :id
      foreign_key :user_id, :users
      String :expertise
      Integer :year_of_study
      Integer :match_slots_remaining
      DateTime :created_at
      DateTime :updated_at

      index :user_id
    end

    create_table(:mentee_profiles) do
      primary_key :id
      foreign_key :user_id, :users
      Text :goals
      Text :background_summary
      Text :availability
      DateTime :created_at
      DateTime :updated_at

      index :user_id
    end

    create_table(:matches) do
      primary_key :id
      foreign_key :mentor_id, :users, null: false
      foreign_key :mentee_id, :users, null: false
      String :status
      foreign_key :admin_id, :users
      Date :start_date
      Date :end_date
      DateTime :created_at
      DateTime :updated_at

      index [:mentor_id, :mentee_id]
      index :status
    end
  end
end