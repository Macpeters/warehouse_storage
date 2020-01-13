# frozen_string_literal: true

require 'rails_helper'

describe Api::StorageBoxesController, type: :controller do
  render_views

  let(:customer) { FactoryBot.create(:customer) }
  let(:storage_box) { FactoryBot.create(:storage_box)}
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
          'adjustments' => []
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

  describe 'index' do
    it 'returns an array of storage_boxes' do
      FactoryBot.create_list(:storage_box, 5)
      get :index, format: :json
      expect(JSON.parse(response.body)['storage_boxes'].count).to eql(5)
    end
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
    it 'validates the storage_box exists' do
      put :update, format: :json, params: { id: 1234 }
      expect(JSON.parse(response.body)).to eql('error' => "This storage box doesn't exist")
    end

    it 'updates a customer level rate_adjustment_threshold' do
      post :create, format: :json, params: params.except('customer_id')
      created = JSON.parse(response.body)
      created['adjustments'] << {
        'adjustment_type' => 'heavy_items_fee',
        'value' => '1',
        'threshold' => { 'min_value' => 0, 'max_value' => 200 }
      }

      put :update, format: :json, params: created
      adjustment = JSON.parse(response.body)['adjustments'][1]
      expect(adjustment['adjustment_type']).to eql('heavy_items_fee')
      expect(adjustment['threshold']['max_value']).to eql(200)
    end

    it 'adds items to the existing storage box' do
      post :create, format: :json, params: params.except('customer_id')
      created = JSON.parse(response.body)
      expect(Item.count).to eql(2)
      created['items'] << {
        'name' => 'Stereo',
        'length' => 3,
        'height' => 2,
        'width' => 3,
        'weight' => 2,
        'value' => 30,
        'adjustments' => []
      }
      put :update, format: :json, params: created
      expect(Item.count).to eql(3)
      expect(Item.last.storage_box_id).to eql(created['id'])
    end

    it 'removes items from the existing storage box' do
      post :create, format: :json, params: params.except('customer_id')
      created = JSON.parse(response.body)
      expect(Item.count).to eql(2)

      created['items'][0]['delete'] = 'true'

      put :update, format: :json, params: created
      expect(Item.count).to eql(1)
    end

    it 'removes any rate_adjustments' do
      post :create, format: :json, params: params.except('customer_id')
      created = JSON.parse(response.body)
      created['adjustments'][0]['delete'] = 'true'

      put :update, format: :json, params: created
      expect(JSON.parse(response.body)['adjustments']).to eql([])
    end

    it 'returns validation errors for rate_adjustments'

    it 'updates an item level rate_adjustment_threshold' do
      post :create, format: :json, params: params.except('customer_id')
      created = JSON.parse(response.body)
      created['items'][1]['adjustments'][0]['threshold']['max_value'] = '200'

      put :update, format: :json, params: created
      expect(JSON.parse(response.body)['items'][1]['adjustments'][0]['threshold']['max_value']).to eql(200)
    end

    it 'removes any thresholds if the associated rate_adjustment was removed' do
      post :create, format: :json, params: params.except('customer_id')
      created = JSON.parse(response.body)
      expect(RateAdjustmentThreshold.count).to eql(1)

      created['items'][1]['adjustments'][0]['delete'] = 'true'

      put :update, format: :json, params: created
      expect(RateAdjustmentThreshold.count).to eql(0)
    end

    it 'returns the fee for any items stored' do
      params['customer_id'] = customer.id
      post :create, format: :json, params: params
      customer.reload

      parsed = JSON.parse(response.body)
      expect(parsed['storage_fee']).to eql(storage_fee)
      expect(parsed['items'].count).to eql(params['items'].count)
    end
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
