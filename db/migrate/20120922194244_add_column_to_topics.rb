class AddColumnToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :close, :boolean, default: false
    add_column :forums, :protect, :boolean, default: false
  end
end
