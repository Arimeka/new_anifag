class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.integer :user_id
      t.integer :forum_id
      t.string :title
      t.text :content

      t.timestamps
    end
    add_index :forums, [:created_at, :title]
  end
end
