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

require 'spec_helper'

describe Forum do
  pending "add some examples to (or delete) #{__FILE__}"
end
