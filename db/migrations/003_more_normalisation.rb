# normalising data

Sequel.migration do
  up do
    alter_table(:profiles) do
      drop_column :nationality
      add_foreign_key :nationality_id, :nationalities
    end
  end

  down do
    alter_table(:profiles) do
      add_column :nationality, String
    end
  end

  change do
    create_table(:user_expertises) do
      primary_key :id
      foreign_key :user_id, :users
      foreign_key :expertise_id, :expertises
      Integer :confidence_level # 1-10
      DateTime :created_at
      DateTime :updated_at

      index :user_id
    end

    create_table(:expertises) do
      primary_key :id
      String :expertise_name
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
    end

    create_table(:nationalities) do
      primary_key :id
      String :country_name
      String :country_code
    end
  end
end