# frozen_string_literal: true

class Customer < ApplicationRecord
  has_one :storage_box, dependent: :destroy

  has_many :rate_adjustments
end
