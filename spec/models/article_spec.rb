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

require 'spec_helper'

describe Article do
  pending "add some examples to (or delete) #{__FILE__}"
end
