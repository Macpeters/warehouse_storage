# frozen_string_literal: true

# discounts or added fees given to specific customers
class RateAdjustment < ApplicationRecord
  belongs_to :adjustable, polymorphic: true

  ADJUSTMENT_TYPES = %i[
    bulk_item_discount
    flat_discount
    large_item_fee
    value_fee
  ].freeze

  # TODO: Does customer B only store large items?
  # Customer B stores large items, and will be charged at $1 per unit of volume.
  def self.calculate_large_item_fee(rate, items, rate_adjustment)
    volume = 0
    items.each do |item|
      volume += item_volume(item)
    end

    rate + rate_adjustment.value * volume
  end

  # Customer A will receive a 10% discount.
  def self.calculate_flat_discount(rate, _items, rate_adjustment)
    rate - percentage_value(rate, rate_adjustment)
  end

  # Customer C is to be charged 5% of the value of the item being stored.
  def self.calculate_item_value_fee(rate, item, rate_adjustment)
    rate + percentage_value(item.value, rate_adjustment)
  end

  # Client D will have a # 5% discount for the first 100 items stored, 10% discount for the next 100, and then 15% on each additional item,
  def self.calculate_bulk_item_discount
    # TODO: This one is very specific - should it be broken up? treated like a special case?
  end

  def self.item_volume(item)
    item.length * item.height * item.width
  end

  def self.percentage_value(value, rate_adjustment)
    value * rate_adjustment.value.to_f / 100
  end
end
