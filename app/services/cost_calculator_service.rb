# frozen_string_literal: true

# Use the customer's rate_adjustments to calculate the final rate
class CostCalculatorService
  FLAT_RATE = 20

  def initialize(params)
    @customer = Customer.find(params[:customer_id])
    @items = params[:items]
    @rate = FLAT_RATE
  end

  def perform
    @customer.rate_adjustments.each do |rate_adjustment|
      @rate = RateAdjustment.send(
        "calculate_#{rate_adjustment.adjustment_type}",
        @rate,
        @items,
        rate_adjustment
      )
    end
    @rate
  end
end
