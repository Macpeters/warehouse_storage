# frozen_string_literal: true

require 'rails_helper'

describe Api::StorageBoxController do
  describe 'rspec' do
    let(:customer) { FactoryBot.create(:customer) }
    let(:flat_rate) { CostCalculatorService::FLAT_RATE }
    let(:items) do
      [
        {
          'name' => 'Fridge',
          'length' => '3',
          'height' => '6',
          'width' => '300',
          'value' => '1000'
        },
        {
          'name' => 'sofa',
          'length' => '6',
          'height' => '4',
          'width' => '3',
          'weight' => '100',
          'value' => '300'
        }
      ]
    end

    it 'charges the flat rate' do
      rate = CostCalculatorService.new(customer_id: customer.id, items: items).perform
      expect(rate).to eql(flat_rate)
    end

    it 'calculates a discount' do
      discount = 10
      expected = flat_rate - flat_rate * (discount.to_f / 100)
      customer

      customer.rate_adjustments << FactoryBot.create(:rate_adjustment, adjustment_type: 'flat_discount', value: discount, customer_id: customer.id)
      rate = CostCalculatorService.new(customer_id: customer.id, items: items).perform

      expect(rate).to eql(expected)
    end

    it 'calculates a fee'
  end
end
