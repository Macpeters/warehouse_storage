# frozen_string_literal: true

class Customer < ApplicationRecord
  has_one :storage_box

  has_many :rate_adjustments
end
