class CreateCatAssociations < ActiveRecord::Migration
  def change
    create_table :cat_associations do |t|
      t.integer :article_id
      t.integer :category_id

      t.timestamps
    end
    add_index :cat_associations, :article_id
    add_index :cat_associations, :category_id
    add_index :cat_associations, [:article_id, :category_id], unique: true
  end
end
