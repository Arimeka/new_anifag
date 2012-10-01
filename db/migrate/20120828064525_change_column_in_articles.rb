class ChangeColumnInArticles < ActiveRecord::Migration
  def up
    change_column :articles, :content, :text
    change_column :articles, :description, :text
  end

  def down
  end
end
