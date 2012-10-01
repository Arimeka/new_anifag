class AddDraftToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :draft, :boolean, default: true
  end
end
