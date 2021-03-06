# frozen_string_literal: true

# This model orchestrates the storing of items
class StorageBox < ApplicationRecord
  belongs_to :customer
  has_many :items, dependent: :destroy

  accepts_nested_attributes_for :items, allow_destroy: true
end
