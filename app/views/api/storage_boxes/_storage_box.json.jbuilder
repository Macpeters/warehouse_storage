json.id storage_box.id
json.customer_id storage_box.customer_id
json.storage_fee storage_box.storage_fee

json.adjustments do
  json.array! storage_box.customer.rate_adjustments do |rate_adjustment|
    json.id rate_adjustment.id
    json.adjustment_type rate_adjustment.adjustment_type
    json.value rate_adjustment.value

    if rate_adjustment.rate_adjustment_threshold
      json.threshold do
        json.id rate_adjustment.rate_adjustment_threshold.id
        json.min_value rate_adjustment.rate_adjustment_threshold.min_value
        json.max_value rate_adjustment.rate_adjustment_threshold.max_value
      end
    end
  end
end

json.items do
  json.array! @storage_box.items do |item|
    json.id item.id
    json.name item.name
    json.length item.length
    json.height item.height
    json.width item.width
    json.weight item.weight
    json.value item.value

    json.adjustments do
      json.array! item.rate_adjustments do |rate_adjustment|
        json.id rate_adjustment.id
        json.adjustment_type rate_adjustment.adjustment_type
        json.value rate_adjustment.value

        if rate_adjustment.rate_adjustment_threshold
          json.threshold do
            json.id rate_adjustment.rate_adjustment_threshold.id
            json.min_value rate_adjustment.rate_adjustment_threshold.min_value
            json.max_value rate_adjustment.rate_adjustment_threshold.max_value
          end
        end
      end
    end
  end
end
