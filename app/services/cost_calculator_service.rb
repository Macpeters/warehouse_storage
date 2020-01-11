# frozen_string_literal: true

# Use the rate_adjustments associated with the customer, as well as with
# each item to calculate the final rate.
class CostCalculatorService
  FLAT_RATE = 20

  def initialize(params)
    @customer = Customer.find(params[:customer_id])
    @rate = FLAT_RATE
  end

  def perform
    items = @customer.storage_box&.items

    customer_rate_adjustments.each do |rate_adjustment|
      @rate = RateAdjustment.send(
        "calculate_#{rate_adjustment.adjustment_type}",
        @rate,
        items,
        rate_adjustment
      )
    end

    items&.each do |item|
      item_rate_adjustments(item).each do |rate_adjustment|
        @rate = RateAdjustment.send(
          "calculate_#{rate_adjustment.adjustment_type}",
          @rate,
          item,
          rate_adjustment
        )
      end
    end

    @rate
  end

  def item_rate_adjustments(item_id)
    RateAdjustment.where(adjustable_type: 'Item', adjustable_id: item_id)
  end

  def customer_rate_adjustments
    RateAdjustment.where(adjustable_type: 'Customer', adjustable_id: @customer.id)
  end
end
