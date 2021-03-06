# frozen_string_literal: true

# discounts or added fees given to specific customers
class RateAdjustment < ApplicationRecord
  belongs_to :adjustable, polymorphic: true
  has_one :rate_adjustment_threshold, dependent: :destroy

  # Threshold required for
    # bulk_items_discount
    # heavy_items_fee
    # large_items_fee
  ADJUSTMENT_TYPES = %w[
    bulk_items_discount
    heavy_items_fee
    large_items_fee
    flat_discount
    heavy_item_fee
    large_item_fee
    item_value_fee
  ].freeze

  validates :adjustment_type, inclusion: { in: ADJUSTMENT_TYPES }

  # -----  Customer Level Adjustments affects multiple items --------

  # Customer B stores large items, and will be charged at $1 per unit of volume.
  def self.calculate_large_items_fee(rate, items, rate_adjustment)
    items = ensure_items_is_array(items)
    threshold = rate_adjustment.rate_adjustment_threshold.max_value
    items.each do |item|
      rate += rate_adjustment.value if item.volume > threshold
    end

    rate
  end

  def self.calculate_heavy_items_fee(rate, items, rate_adjustment)
    ensure_items_is_array(items)
    threshold = rate_adjustment.rate_adjustment_threshold.max_value
    items.each do |item|
      rate += rate_adjustment.value if item.weight > threshold
    end

    rate
  end

  # Client D will have a # 5% discount for the first 100 items stored, 10% discount for the next 100,
  # and then 15% on each additional item,
  def self.calculate_bulk_items_discount(rate, items, rate_adjustment)
    ensure_items_is_array(items)
    discount = 0
    if rate_adjustment.rate_adjustment_threshold.max_value.present?
      items_count = items[rate_adjustment.rate_adjustment_threshold.min_value..rate_adjustment.rate_adjustment_threshold.max_value].count
    else
      # with no upper limit, the rule applies to all items above the min_value
      items_count = items.count - rate_adjustment.rate_adjustment_threshold.min_value
    end

    items_count.times { discount += rate_adjustment.value }
    rate - discount
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

  def self.calculate_heavy_item_fee(rate, item, rate_adjustment)
    rate + rate_adjustment.value * item.weight
  end

  # HELPERS
  def self.percentage_value(value, rate_adjustment)
    value.to_f * rate_adjustment.value.to_f / 100
  end

  def ensure_items_is_array(items)
    return items if items.is_a?(Array)

    [items]
  end
end
