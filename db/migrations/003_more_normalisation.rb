# normalising data

Sequel.migration do
  alter_table(:profiles) do
    drop_column :nationality
    add_foreign_key :nationality_id, :nationalities
  end
  change do
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