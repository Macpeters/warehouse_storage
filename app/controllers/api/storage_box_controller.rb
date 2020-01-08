class Api::StorageBoxController < Api::BaseController

  def update
  end

  def create 
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