# frozen_string_literal: true

FactoryBot.define do
  factory :rate_adjustment do
    adjustment_type { "flat_discount" }
  end
end
