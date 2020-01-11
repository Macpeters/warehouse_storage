# frozen_string_literal: true

require 'rails_helper'

describe Api::StorageBoxController do
  describe 'rspec' do
    let(:customer) { FactoryBot.create(:customer) }
    let(:storage_box) { FactoryBot.create(:storage_box, customer: customer) }
    let(:flat_rate) { CostCalculatorService::FLAT_RATE }

    it 'charges the flat rate' do
      rate = CostCalculatorService.new(customer_id: customer.id).perform
      expect(rate).to eql(flat_rate)
    end

    it 'calculates a discount' do
      discount = 10
      expected = flat_rate - flat_rate * (discount.to_f / 100)
      customer
      
      FactoryBot.create(:rate_adjustment, adjustment_type: 'flat_discount', value: discount, adjustable_id: customer.id, adjustable_type: 'Customer')
      rate = CostCalculatorService.new(customer_id: customer.id).perform

      expect(rate).to eql(expected)
    end

    it 'calculates a fee' do
      fee_rate = 5
      item = FactoryBot.create(:item, value: 100, storage_box: storage_box)
      expected = flat_rate + item.value * fee_rate.to_f / 100

      FactoryBot.create(:rate_adjustment, adjustment_type: 'item_value_fee', value: fee_rate, adjustable_id: item.id, adjustable_type: 'Item')
      rate = CostCalculatorService.new(customer_id: customer.id).perform

      expect(rate).to eql(expected)
    end
  end
end
