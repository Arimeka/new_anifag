class CreateTableForums < ActiveRecord::Migration
  def up
    create_table :forums do |t|
      t.integer :user_id
      t.string :title
      t.text :content

      t.timestamps
    end
    add_index :forums, :user_id
  end

  def down
  end
end
