# frozen_string_literal: true

# Find the monthly rate for the customer by calculating the flat rate
# along with any customer and item level rate_adjustments
class CostCalculatorService
  FLAT_RATE = 20

  def initialize(params)
    @customer = Customer.find(params[:customer_id])
  end

  def perform
    return nil unless @customer.storage_box.present?

    @items = @customer.storage_box.items
    return nil unless @items.present?

    @rate = @items.count * FLAT_RATE

    calculate_customer_level_adjustments
    calculate_item_level_adjustments

    @customer.storage_box.update(storage_fee: @rate)
    @rate
  end

  def calculate_customer_level_adjustments
    @customer.rate_adjustments.each do |rate_adjustment|
      @rate = RateAdjustment.send(
        "calculate_#{rate_adjustment.adjustment_type}",
        @rate,
        @items,
        rate_adjustment
      )
    end
  end

  def calculate_item_level_adjustments
    @items&.each do |item|
      item.rate_adjustments.each do |rate_adjustment|
        @rate = RateAdjustment.send(
          "calculate_#{rate_adjustment.adjustment_type}",
          @rate,
          item,
          rate_adjustment
        )
      end
    end
  end
end
