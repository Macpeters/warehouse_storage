# frozen_string_literal: true

require 'rails_helper'

describe Api::StorageBoxController do
  describe 'rspec' do
    let(:customer) { FactoryBot.create(:customer) } 
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

    it 'performs all the calculations' do
      CostCalculatorService.new(customer_id: customer.id, items: items)
    end
  end
end
