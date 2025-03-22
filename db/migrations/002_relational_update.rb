# New schema. Relational mapping. Not perfect, but functional.

Sequel.migration do
  change do
    drop_table(:users)

    create_table(:users) do
      primary_key :id
      String :username
      String :email
      String :role # mentor, mentee, admin
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
      String :first_name
      String :last_name
      String :nationality
      Date :date_of_birth
      String :gender
      String :profile_picture
      Text :bio_brief
      Text :bio_detailed
      DateTime :created_at
      DateTime :updated_at

      index :user_id
    end

    create_table(:mentor_profiles) do
      primary_key :id
      foreign_key :user_id, :users
      Integer :year_of_study
      Integer :num_matches # Cannot exceed max_matches
      Integer :max_matches # This should only be set by mentor
      Text :badges
      DateTime :created_at
      DateTime :updated_at

      index :user_id
    end

    create_table(:mentee_profiles) do
      primary_key :id
      foreign_key :user_id, :users
      Boolean :availability # true or false
      DateTime :created_at
      DateTime :updated_at

      index :user_id
    end

    create_table(:matches) do
      primary_key :id
      foreign_key :mentor_id, :users
      foreign_key :mentee_id, :users
      String :status # pending, matched, completed or cancelled
      Text :application_message
      Date :start_date
      Date :end_date
      DateTime :created_at
      DateTime :updated_at

      index [:mentor_id, :mentee_id]
      index :status
    end

    create_table(:user_expertises) do
      primary_key :id
      foreign_key :user_id, :users
      String :skill
      DateTime :created_at
      DateTime :updated_at
      
      index :skill
    end

    create_table(:user_languages) do
      primary_key :id
      foreign_key :user_id, :users
      String :language
      DateTime :created_at
      DateTime :updated_at

      index :user_id
    end
  end
end