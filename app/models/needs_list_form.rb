# frozen_string_literal: true

class NeedsListForm
  include ActiveModel::Model

  attr_accessor :needs_list
  attr_accessor :other_need
end