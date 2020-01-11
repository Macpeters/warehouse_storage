# frozen_string_literal: true

require 'rails_helper'

describe RateAdjustment do
  let(:customer) { FactoryBot.create(:customer) }
  let(:storage_box) { FactoryBot.create(:storage_box, customer: customer) }
  let(:flat_rate) { CostCalculatorService::FLAT_RATE }

  describe 'validations' do
    it 'validates adjustment_type is in the whitelist' do
      expect do
        FactoryBot.create(:rate_adjustment, adjustment_type: 'bad_type')
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'calculate_flat_discount' do
    it 'calculates a single discount for the rate based on the value of the rate_adjustment' do
      items = FactoryBot.build_list(:item, 3)

      discount = 10
      expected = flat_rate - flat_rate * (discount.to_f / 100)
      customer

      rate_adjustment = FactoryBot.create(:rate_adjustment, adjustment_type: 'flat_discount', value: discount, adjustable_id: customer.id, adjustable_type: 'Customer')

      rate = RateAdjustment.calculate_flat_discount(flat_rate, items, rate_adjustment)
      expect(rate).to eql(expected)
    end
  end

  describe 'calculate_large_items_fee' do
    it 'adjusts the fee for any item that meets the threshold' do
      items = [
        FactoryBot.create(:item, length: 100, width: 100, height: 100),
        FactoryBot.create(:item, length: 75, width: 75, height: 75)
      ]
      rate_adjustment = FactoryBot.create(:rate_adjustment, value: 1, adjustable_id: customer.id, adjustable_type: 'Customer', adjustment_type: 'bulk_items_discount')
      FactoryBot.create(:rate_adjustment_threshold, min_value: nil, max_value: 50, rate_adjustment: rate_adjustment)

      expected = flat_rate + (rate_adjustment.value * items.count)

      rate = RateAdjustment.calculate_large_items_fee(flat_rate, items, rate_adjustment)
      expect(rate).to eql(expected)
    end

    it 'doesnt charge for items that do not meet the threshold' do
      items = [
        FactoryBot.create(:item, length: 100, width: 100, height: 100),
        FactoryBot.create(:item, length: 1, width: 1, height: 1)
      ]
      rate_adjustment = FactoryBot.create(:rate_adjustment, value: 1, adjustable_id: customer.id, adjustable_type: 'Customer', adjustment_type: 'bulk_items_discount')
      FactoryBot.create(:rate_adjustment_threshold, min_value: nil, max_value: 50, rate_adjustment: rate_adjustment)

      expected = flat_rate + rate_adjustment.value

      rate = RateAdjustment.calculate_large_items_fee(flat_rate, items, rate_adjustment)
      expect(rate).to eql(expected)
    end
  end

  describe 'calculate_bulk_items_discount' do
    it 'calculates a fee for the first 100 items'
    it 'calculates a fee for the second 100 items'
    it 'calculates a fee for each additional item past 200 items'
  end

  describe 'heavy_items_fee' do
    it 'calculates a fee based on the weight of the item'
  end

  describe 'heavy_item_fee' do
    it 'calculates a fee based on the weight of the item'
  end

  describe 'calculate_item_value_fee' do
    it 'calculates a fee based on the value of the item and the rate_adjustment' do
      fee_rate = 5
      item = FactoryBot.create(:item, value: 100, storage_box: storage_box)
      expected = flat_rate + item.value * fee_rate.to_f / 100

      rate_adjustment = FactoryBot.create(:rate_adjustment, adjustment_type: 'item_value_fee', value: fee_rate, adjustable_id: item.id, adjustable_type: 'Item')
      rate = RateAdjustment.calculate_item_value_fee(flat_rate, item, rate_adjustment)

      expect(rate).to eql(expected)
    end
  end

  describe 'calculate_large_item_fee' do
    it 'calculates a fee based on the volume of the item and the rate_adjustment'
    it 'requires width, height, and length values to be non-nil'
    it 'only adds the fee when items are above a threshold volume'
  end

  describe 'percentage_value' do
    it 'returns the x percent of y' do
      rate_adjustment = FactoryBot.create(:rate_adjustment, value: 20, adjustable_id: customer.id, adjustable_type: 'Customer')
      expect(RateAdjustment.percentage_value(100, rate_adjustment)).to eql(20.0)
    end

    it 'handles nil values without complaining' do
      rate_adjustment = FactoryBot.create(:rate_adjustment, value: nil, adjustable_id: customer.id, adjustable_type: 'Customer')
      expect(RateAdjustment.percentage_value(100, rate_adjustment)).to eql(0.0)
    end
  end
end
