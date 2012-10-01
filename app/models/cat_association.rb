# == Schema Information
#
# Table name: cat_associations
#
#  id          :integer          not null, primary key
#  article_id  :integer
#  category_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class CatAssociation < ActiveRecord::Base
  attr_accessible :category_id
  
  belongs_to :article
  belongs_to :category
end
