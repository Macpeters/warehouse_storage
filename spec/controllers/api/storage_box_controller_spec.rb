# frozen_string_literal: true

require 'rails_helper'

describe Api::StorageBoxesController, type: :controller do
  let(:customer) { FactoryBot.create(:customer) }
  let(:params) do
    {
      'customer_id' => '1234',
      'adjustments' => [
        {
          'adjustment_type' => 'flat_discount',
          'value' => '5'
        }
      ],
      'items' => [
        {
          'id' => '242',
          'name' => 'Fridge',
          'length' => '3',
          'height' => '6',
          'width' => '300',
          'value' => '1000',
          'adjustments' => [],
          'delete' => 'true',
        },
        {
          'name' => 'sofa',
          'length' => '6',
          'height' => '4',
          'width' => '3',
          'weight' => '100',
          'value' => '300',
          'adjustments' => [
            {
              'adjustment_type' => 'bulk_item_discount',
              'value' => '2',
              'threshold' => {
                'min_value' => 0,
                'max_value' => 100
              }
            }
          ]
        }
      ]
    }
  end

  describe 'create' do
    it 'creates a new customer if no customer_id is passed in' do
      expect(Customer.all.count).to eql(0)
      post :create, format: :json, params: params.except('customer_id')
      expect(Customer.all.count).to eql(1)
    end

    it 'returns validation errors for the customer'

    it 'ensures an existing customer is found' do
      post :create, format: :json, params: params
      expect(response.status).to eql(404)
      expect(JSON.parse(response.body)).to eql({ 'error' => 'No Customer Found with id 1234' })
    end

    it 'creates a new storage box' do
      customer
      expect(customer.storage_box).to be_nil
      post :create, format: :json, params: params
      expect(response.status).to eql(200)
      customer.reload
      expect(customer.storage_box).not_to be_nil
    end

    it 'adds items to the new storage box' do
      customer
      post :create, format: :json, params: params
    end

    it 'adds any rate_adjustments'
    it 'returns validation errors for rate_adjustments'
    it 'adds any thresholds'
    it 'returns the fee for any items stored'
  end

  describe 'update' do
    it 'validates the storage_box exists'
    it 'validates the storage_box belongs to the customer_id'
    it 'adds items to the existing storage box'
    it 'removes items from the existing storage box'
    it 'adds any rate_adjustments'
    it 'removes any rate_adjustments'
    it 'returns validation errors for rate_adjustments'
    it 'adds any thresholds'
    it 'removes any thresholds'
    it 'returns the fee for any items stored'
  end

  describe 'show' do
    it 'returns the fee for any items stored'
    it 'returns a json object with all the items stored and their rate_adjustments, thresholds, etc'
  end
end
