# frozen_string_literal: true

# discounts or added fees given to specific customers
class RateAdjustment < ApplicationRecord
  belongs_to :adjustable, polymorphic: true
  has_one :rate_adjustment_threshold, dependent: :destroy

  ADJUSTMENT_TYPES = %w[
    bulk_item_discount # threshold required
    bulk_items_discount # threshold required
    large_items_fee # threshold required
    flat_discount
    heavy_item_fee
    large_item_fee
    item_value_fee
  ].freeze

  validates :adjustment_type, inclusion: { in: ADJUSTMENT_TYPES }

  # -----  Customer Level Adjustments affects multiple items --------

  # Customer B stores large items, and will be charged at $1 per unit of volume.
  def self.calculate_large_items_fee(rate, items, rate_adjustment)
    threshold = rate_adjustment.rate_adjustment_threshold.max_value
    items.each do |item|
      rate += rate_adjustment.value if item.volume > threshold
    end

    rate
  end

  def self.heavy_items_fee(rate, item, rate_adjustment)
  end

  # Client D will have a # 5% discount for the first 100 items stored, 10% discount for the next 100,
  # and then 15% on each additional item,
  def self.calculate_bulk_items_discount(rate, items, rate_adjustment)
    # get the rate_adjustment thresholds
    # if no threshold, all items get the same bulk discount.
    # for each threshold, calculate the discount
  end

  # Customer A will receive a 10% discount.
  def self.calculate_flat_discount(rate, _items, rate_adjustment)
    rate - percentage_value(rate, rate_adjustment)
  end

  # ----- Item Level Adjustments for Single Items ---------

  # Customer C is to be charged 5% of the value of the item being stored.
  def self.calculate_item_value_fee(rate, item, rate_adjustment)
    rate + percentage_value(item.value, rate_adjustment)
  end

  # Customer B stores large items, and will be charged at $1 per unit of volume.
  def self.calculate_large_item_fee(rate, item, rate_adjustment)
    rate + rate_adjustment.value * item.volume
  end

  def self.heavy_item_fee(rate, item, rate_adjustment)
  end

  # HELPERS
  def self.percentage_value(value, rate_adjustment)
    value.to_f * rate_adjustment.value.to_f / 100
  end
end
