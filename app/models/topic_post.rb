# == Schema Information
#
# Table name: topic_posts
#
#  id         :integer          not null, primary key
#  content    :text
#  user_id    :integer
#  topic_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TopicPost < ActiveRecord::Base
  attr_accessible :content, :topic_id
  
  belongs_to :topic
  belongs_to :user
  
  validates :user_id, presence: true
  validates :topic_id, presence: true
  validates :content, presence: true
  
  default_scope order: 'topic_posts.created_at ASC'
end
