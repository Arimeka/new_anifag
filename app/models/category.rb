# == Schema Information
#
# Table name: categories
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  title       :string(255)
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Category < ActiveRecord::Base
  attr_accessible :description, :name, :title
  
  has_many :cat_associations, dependent: :destroy
  has_many :articles, through: :cat_associations
  
  validates :title, presence: true, length: { maximum: 90 }
  validates :name, presence: true, length: { maximum: 90 }
  
  default_scope order: 'categories.name'
  
  def to_param
    "#{id}-#{name}"
  end
end
