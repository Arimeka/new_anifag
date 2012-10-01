class AddIndexes < ActiveRecord::Migration
  def up
    add_index :articles, :user_id
    add_index :articles, [:created_at,:title]
    add_index :topics, :user_id
    add_index :topics, :forum_id
    add_index :topics, [:created_at,:title]
    add_column :topics, :last_post_at, :datetime
    add_index :topics, :last_post_at
  end

  def down
  end
end
