# frozen_string_literal: true

class Customer < ApplicationRecord
  has_one :storage_box, dependent: :destroy

  has_many :rate_adjustments

  def rate_adjustments
    RateAdjustment.where(adjustable_type: 'Customer', adjustable_id: id)
  end
end
