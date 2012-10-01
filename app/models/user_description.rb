# == Schema Information
#
# Table name: user_descriptions
#
#  id         :integer          not null, primary key
#  role       :string(255)
#  links      :string(255)
#  sign       :string(255)
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserDescription < ActiveRecord::Base
  attr_accessible :role, :sign, :links
  belongs_to :user
  
  validates :user_id, presence: true, uniqueness: true
  validates :role, presence: true
  validates :sign, length: { maximum: 70 }
  validates :links, length: { maximum: 200 }
end
