class CreateUserDescriptions < ActiveRecord::Migration
  def change
    create_table :user_descriptions do |t|
      t.string :role
      t.string :links
      t.string :sign
      t.integer :user_id

      t.timestamps
    end
    add_index :user_descriptions, :user_id, unique: true
  end
end
