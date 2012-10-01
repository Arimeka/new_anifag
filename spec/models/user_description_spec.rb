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

require 'spec_helper'

describe UserDescription do
  pending "add some examples to (or delete) #{__FILE__}"
end
