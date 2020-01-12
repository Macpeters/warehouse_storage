# frozen_string_literal: true

require 'rails_helper'

describe Api::StorageBoxesController, type: :controller do
  render_views

  let(:customer) { FactoryBot.create(:customer) }
  let(:storage_fee) { 38.0 }
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
              'adjustment_type' => 'item_value_fee',
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
    it 'renders the view' do
      params['customer_id'] = customer.id
      post :create, format: :json, params: params
      parsed = JSON.parse(response.body)
      expect(parsed['customer_id']).to eql(customer.id)
    end

    it 'creates a new customer if no customer_id is passed in' do
      expect(Customer.all.count).to eql(0)
      post :create, format: :json, params: params.except('customer_id')
      expect(Customer.all.count).to eql(1)
    end

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
      expect(Item.all.count).to eql(0)
      post :create, format: :json, params: params
      expect(Item.all.count).to eql(params['items'].count)
    end

    it 'adds any rate_adjustments for the customer' do
      params['customer_id'] = customer.id
      post :create, format: :json, params: params

      rate_adjustment = RateAdjustment.where(adjustable_type: 'Customer', adjustable_id: customer.id).first
      expect(rate_adjustment.present?).to be true
    end

    it 'adds any rate_adjustments and thresholds for items' do
      post :create, format: :json, params: params.except('customer_id')

      sofa = Item.find_by(name: 'sofa')
      rate_adjustment = RateAdjustment.where(adjustable_type: 'Item', adjustable_id: sofa.id).first
      expect(rate_adjustment.rate_adjustment_threshold.present?).to be true
    end

    it 'returns validation errors for rate_adjustments'

    it 'returns the fee for any items stored' do
      customer
      post :create, format: :json, params: params
      expect(JSON.parse(response.body)['storage_fee']).to eql(storage_fee)
    end

    it 'returns the items stored' do
      post :create, format: :json, params: params.except('customer_id')
      parsed = JSON.parse(response.body)
      expect(parsed['items'].count).to eql(params['items'].count)
    end
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
    it 'validates the storage_box exists' do
      get :show, format: :json, params: { id: 66 }
      expect(JSON.parse(response.body))
        .to eql('error' => "This storage box doesn't exist")
    end

    it 'returns the fee and any items stored' do
      params['customer_id'] = customer.id
      post :create, format: :json, params: params
      customer.reload

      get :show, format: :json, params: { id: customer.storage_box.id }
      parsed = JSON.parse(response.body)
      expect(parsed['storage_fee']).to eql(storage_fee)
      expect(parsed['items'].count).to eql(params['items'].count)
    end
  end
end
