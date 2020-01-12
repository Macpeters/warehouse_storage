class Api::StorageBoxesController < Api::BaseController
  def update
  end

  def create
    customer = Customer.create if params['customer_id'].blank?
    customer ||= Customer.find_by(params['customer_id'])
    return render json: { error: "No Customer Found with id #{params['customer_id']}"}.to_json, status: 404 if customer.blank?
    return render json: { error: "There was a problem creating this customer: #{customer.errors.full_messages}"}.to_json, status: 404 unless customer.valid?

    customer.storage_box ||= StorageBox.create(customer: customer)

    # for each params[:items]
    # create the item
    # create any rate_adjustment along with any threshold
    # return any validation errors

    # calculate the fee for all items stored
    # return the fee
    render json: { something: 'here' }.to_json, status: 200
  end

  def show
  end

  private

  def storage_box_params
    params.permit(
      :items_attributes, :id, :customer_id
    )
  end
end