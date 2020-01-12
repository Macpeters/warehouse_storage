# frozen_string_literal: true

# Items are handled by the StorageBox
class Item < ApplicationRecord
  belongs_to :storage_box

  def volume
    length.to_i * height.to_i * width.to_i
  end

  def rate_adjustments
    RateAdjustment.where(adjustable_type: 'Item', adjustable_id: id)
  end
end
