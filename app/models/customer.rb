# frozen_string_literal: true

# I'm not sure I want to keep this
class Customer < ApplicationRecord
  has_one :storage_box
end
