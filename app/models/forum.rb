# == Schema Information
#
# Table name: forums
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  title      :string(255)
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  protect    :boolean          default(FALSE)
#

class Forum < ActiveRecord::Base
  attr_accessible :content, :title, :protect
  
  belongs_to :user
  
  has_many :topics, dependent: :destroy
  
  validates :user_id, presence: true
  validates :title, presence: true, length: { maximum: 90 }
  
  default_scope order: 'forums.id ASC'
end
