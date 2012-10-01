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

require 'spec_helper'

describe TopicPost do
  pending "add some examples to (or delete) #{__FILE__}"
end
