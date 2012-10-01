class CreateTopicPosts < ActiveRecord::Migration
  def change
    create_table :topic_posts do |t|
      t.text :content
      t.integer :user_id
      t.integer :topic_id

      t.timestamps
    end
    add_index :topic_posts, :user_id
    add_index :topic_posts, :topic_id
    add_index :topic_posts, :created_at
  end
end
