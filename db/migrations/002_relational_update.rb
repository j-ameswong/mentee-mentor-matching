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
      Boolean :approved
      Boolean :first_time_login
      DateTime :created_at
      DateTime :updated_at

      index :user_id
    end

    create_table(:profiles) do
      primary_key :id
      foreign_key :user_id, :users
      foreign_key :nationality_id, :nationalities
      String :first_name
      String :last_name
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
      foreign_key :expertise, :expertises
      DateTime :created_at
      DateTime :updated_at
      
      index :skill
    end

    create_table(:expertises) do
      primary_key :id
      String :expertise_name
      Integer :confidence_level # 1-10
      DateTime :created_at
      DateTime :updated_at
    end

    create_table(:user_languages) do
      primary_key :id
      foreign_key :user_id, :users
      foreign_key :language_id, :languages
      DateTime :created_at
      DateTime :updated_at

      index :user_id
    end

    create_table(:languages) do
      primary_key :id
      String :language_name
      String :native_name
      String :language_code
      DateTime :created_at
      DateTime :updated_at
    end

    create_table(:nationalities) do
      primary_key :id
      String :country_name
      String :country_code
      DateTime :created_at
      DateTime :updated_at
    end
  end
end