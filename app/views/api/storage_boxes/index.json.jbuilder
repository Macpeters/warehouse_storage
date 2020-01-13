# frozen_string_literal: true

json.storage_boxes do
  json.array! @storage_boxes do |storage_box|
    json.id storage_box.id
    json.customer_id storage_box.customer_id
    json.storage_fee storage_box.storage_fee
  end
end
