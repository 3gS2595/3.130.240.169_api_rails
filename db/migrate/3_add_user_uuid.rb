class AddUserUuid < ActiveRecord::Migration[5.2]
  def up
    # Add UUID columns
    add_column :users,    :uuid, :uuid, null: false, default: -> { "gen_random_uuid()" }


    # Migrate primary keys from UUIDs to IDs
    remove_column :users,    :id
    rename_column :users,    :uuid, :id
    execute "ALTER TABLE users    ADD PRIMARY KEY (id);"

  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
