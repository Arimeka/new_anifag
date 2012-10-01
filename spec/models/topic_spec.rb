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

require 'spec_helper'

describe Topic do
  pending "add some examples to (or delete) #{__FILE__}"
end
