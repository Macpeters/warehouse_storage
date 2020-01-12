# frozen_string_literal: true

# See documentation (README) for input/output format.
# All methods will return the items and fees
class Api::StorageBoxesController < Api::BaseController
  def update
  end

  def create
    customer = Customer.create if params['customer_id'].blank?
    customer ||= Customer.find_by(params['customer_id'])
    return render json: { error: "No Customer Found with id #{params['customer_id']}"}.to_json, status: 404 if customer.blank?
    return render json: { error: "There was a problem creating this customer: #{customer.errors.full_messages}"}.to_json, status: 404 unless customer.valid?

    customer.storage_box ||= StorageBox.create(customer: customer)

    # The customer level rate_adjustments
    params['adjustments'].each do |adjustment_attributes|
      rate_adjustment = create_rate_adjustment(adjustment_attributes, 'Customer', customer.id)
      next unless adjustment_attributes['threshold']

      create_rate_adjustment_threshold(adjustment_attributes['threshold'], rate_adjustment)
    end

    params['items'].each do |item_attributes|
      item = create_item(item_attributes, customer.storage_box)
      next unless item_attributes['adjustments']

      item_attributes['adjustments'].each do |adjustment_attributes|
        rate_adjustment = create_rate_adjustment(adjustment_attributes, 'Item', item.id)
        next unless adjustment_attributes['threshold']

        create_rate_adjustment_threshold(adjustment_attributes['threshold'], rate_adjustment)
      end
    end
    # TODO: collect and return any validation errors

    @storage_box = customer.storage_box
    CostCalculatorService.new(customer_id: customer.id).perform
    @storage_box.reload
  end

  def show
    @storage_box = StorageBox.find_by(params['id'])
    return render json: { error: "This storage box doesn't exist"}.to_json, status: 404 if @storage_box.blank?
  end

  private

  # TODO: use item_params instead of hard-coding these
  def create_item(item_attributes, storage_box)
    Item.create(
      name: item_attributes['name'],
      length: item_attributes['length'],
      width: item_attributes['width'],
      height: item_attributes['height'],
      weight: item_attributes['weight'],
      storage_box: storage_box
    )
  end

  # TODO: use rate_adjustment_params instead of hard-coding these
  def create_rate_adjustment(adjustment_attributes, adjusted_type, adjusted_id)
    RateAdjustment.create(
      adjustment_type: adjustment_attributes['adjustment_type'],
      value: adjustment_attributes['value'],
      adjustable_type: adjusted_type,
      adjustable_id: adjusted_id
    )
  end

  def create_rate_adjustment_threshold(threshold_attributes, rate_adjustment)
    RateAdjustmentThreshold.create(
      min_value:  threshold_attributes['min_value'],
      max_value: threshold_attributes['max_value'],
      rate_adjustment: rate_adjustment
    )
  end

  def storage_box_params
    params.permit(
      :items_attributes, :id, :customer_id
    )
  end
end
