# frozen_string_literal: true 

class CostCalculatorService
  FLAT_RATE = 20

  def initialize(params)
    @customer = Customer.find(params[:customer_id])
    @items = params[:items]
    @rate = FLAT_RATE
  end

  def perform
    calculate_discounts
    calculate_added_fees
    rate
  end

  private

  def calculate_discounts
    # for each customer.discount, adjust the rate
  end

  def calculate_added_fees
    # for each customer.fee, adjust the rate
  end
end
