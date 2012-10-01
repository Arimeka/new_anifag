# == Schema Information
#
# Table name: articles
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  content          :text
#  title            :string(255)
#  description      :text
#  permalink        :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  source           :string(255)
#  keywords         :string(255)
#  meta_description :string(255)
#  draft            :boolean          default(TRUE)
#  tags             :string(255)
#

class Article < ActiveRecord::Base
  attr_accessible :content, :description, :permalink, :title, :source, 
                  :keywords, :meta_description, :draft, :tags, :created_at, :updated_at
  attr_taggable :tags
  
  include PgSearch
  multisearchable :against => [:content, :title]
  
  belongs_to :user
  has_many :cat_associations, dependent: :destroy
  has_many :categories, through: :cat_associations
  
  validates :user_id, presence: true
  validates :title, presence: true, length: { maximum: 90 }
  validates :content, presence: true
  
  default_scope order: 'articles.created_at DESC'
  
  scope :not_draft, where(:draft => false)
  scope :last_year, lambda { |year| where(created_at: Time.new(year.to_i)..Time.new(year.to_i + 1)) }
  scope :last_month, lambda { |year, month| where(created_at: Time.new(year.to_i, month.to_i)..Time.new(year.to_i,month.to_i + 1)) }
  scope :end_year, lambda { |year, month| where(created_at: Time.new(year.to_i, month.to_i)..Time.new(year.to_i + 1,1)) }
    
  def to_param
    "#{id}-#{permalink}"  
  end
end
