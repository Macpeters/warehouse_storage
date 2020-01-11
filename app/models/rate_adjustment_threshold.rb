# frozen_string_literal: true

# Items are handled by the StorageBox
class RateAdjustmentThreshold < ApplicationRecord
  belongs_to :rate_adjustment
end
