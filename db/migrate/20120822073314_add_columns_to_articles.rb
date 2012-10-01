class AddColumnsToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :keywords, :string
    add_column :articles, :meta_description, :string
  end
end
