# frozen_string_literal: true

# See documentation (README) for input/output format.
# All methods will return the items and fees
class Api::StorageBoxesController < Api::BaseController
  def update
    @storage_box = StorageBox.find_by(params['id'])
    return render json: { error: "This storage box doesn't exist" }.to_json, status: 404 if @storage_box.blank?

    customer = @storage_box.customer
    # The customer level rate_adjustments
    params['adjustments'].each do |adjustment_attributes|
      create_or_update_rate_adjustment(adjustment_attributes, 'Customer', customer.id)
    end

    params['items'].each do |item_attributes|
      create_or_update_item(item_attributes, @storage_box)
    end

    @storage_box.reload
  end

  def create
    customer = Customer.create if params['customer_id'].blank?
    customer ||= Customer.find_by(params['customer_id'])
    return render json: { error: "No Customer Found with id #{params['customer_id']}"}.to_json, status: 404 if customer.blank?
    return render json: { error: "There was a problem creating this customer: #{customer.errors.full_messages}"}.to_json, status: 404 unless customer.valid?

    customer.storage_box ||= StorageBox.create(customer: customer)

    # The customer level rate_adjustments
    params['adjustments'].each do |adjustment_attributes|
      create_or_update_rate_adjustment(adjustment_attributes, 'Customer', customer.id)
    end

    params['items'].each do |item_attributes|
      create_or_update_item(item_attributes, customer.storage_box)
    end
    # TODO: collect and return any validation errors

    @storage_box = customer.storage_box
    CostCalculatorService.new(customer_id: customer.id).perform
    @storage_box.reload
  end

  def show
    @storage_box = StorageBox.find_by(params['id'])
    return render json: { error: "This storage box doesn't exist" }.to_json, status: 404 if @storage_box.blank?
  end

  private

  # TODO: Break these out into a service or something
  def create_or_update_item(item_attributes, storage_box)
    item = Item.find_by(id: item_attributes['id']) if item_attributes['id']

    if item.blank?
      item = Item.create(item_params(item_attributes, storage_box))
    elsif item_attributes['delete'] == 'true'
      item.destroy
    else
      item.update(item_params(item_attributes, storage_box))
    end
    return if item_attributes['delete'] == 'true'
    return unless item_attributes['adjustments']

    item_attributes.dig('adjustments').each do |adjustment_attributes|
      create_or_update_rate_adjustment(adjustment_attributes, 'Item', item.id)
    end
  end

  def create_or_update_rate_adjustment(adjustment_attributes, adjusted_type, adjusted_id)
    rate_adjustment = RateAdjustment.find_by(id: adjustment_attributes['id']) if adjustment_attributes['id']

    if rate_adjustment.blank?
      rate_adjustment = RateAdjustment.create(rate_adjustment_params(adjustment_attributes, adjusted_type, adjusted_id))
    elsif adjustment_attributes['delete'] == 'true'
      rate_adjustment.rate_adjustment_threshold&.destroy
      rate_adjustment.destroy!
    else
      rate_adjustment.update(rate_adjustment_params(adjustment_attributes, rate_adjustment.adjustable_type, rate_adjustment.adjustable_id))
    end
    return if adjustment_attributes['delete'] == 'true'
    return unless adjustment_attributes['threshold']

    create_or_update_rate_adjustment_threshold(adjustment_attributes['threshold'], rate_adjustment)
  end

  def create_or_update_rate_adjustment_threshold(threshold_attributes, rate_adjustment)
    threshold = RateAdjustmentThreshold.find_by(id: threshold_attributes.dig('id'))
    if threshold
      threshold.update(rate_adjustment_threshold_params(threshold_attributes, threshold.rate_adjustment))
    else
      RateAdjustmentThreshold.create(rate_adjustment_threshold_params(threshold_attributes, rate_adjustment))
    end
  end

  def item_params(item_attributes, storage_box)
    {
      name: item_attributes['name'],
      length: item_attributes['length'],
      width: item_attributes['width'],
      height: item_attributes['height'],
      weight: item_attributes['weight'],
      storage_box: storage_box
    }
  end

  def rate_adjustment_threshold_params(threshold_attributes, rate_adjustment)
    {
      min_value:  threshold_attributes['min_value'],
      max_value: threshold_attributes['max_value'],
      rate_adjustment: rate_adjustment
    }
  end

  def rate_adjustment_params(attributes, adjusted_type, adjusted_id)
    {
      adjustment_type: attributes['adjustment_type'],
      value: attributes['value'],
      adjustable_type: adjusted_type,
      adjustable_id: adjusted_id
    }
  end

  def storage_box_params
    params.permit(
      :items_attributes, :id, :customer_id
    )
  end
end
