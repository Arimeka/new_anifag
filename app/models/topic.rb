# == Schema Information
#
# Table name: topics
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  forum_id     :integer
#  title        :string(255)
#  content      :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  last_post_at :datetime
#  close        :boolean          default(FALSE)
#

class Topic < ActiveRecord::Base
  attr_accessible :content, :title, :forum_id, :last_post_at, :close
  
  belongs_to :forum
  belongs_to :user
  
  has_many :topic_posts, dependent: :destroy
  
  validates :user_id, presence: true
  validates :forum_id, presence: true
  validates :title, presence: true, length: { maximum: 90 }
  validates :content, presence: true
  
  default_scope order: 'topics.last_post_at DESC'
end
