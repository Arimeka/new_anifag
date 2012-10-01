class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.integer :user_id
      t.string :content
      t.string :title
      t.string :description
      t.string :permalink

      t.timestamps
    end
    add_index :articles, [:user_id, :created_at, :title]
  end
end
