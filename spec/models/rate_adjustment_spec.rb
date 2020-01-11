# frozen_string_literal: true

require 'rails_helper'

describe Api::StorageBoxController do
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

  describe 'rspec' do
    describe 'calculate_large_item_fee'
    describe 'calculate_flat_discount'
    describe 'calculate_value_fee'
    describe 'calculate_bulk_item_discount'
    describe 'item_volume'
  end
end
