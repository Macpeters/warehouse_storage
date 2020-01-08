# frozen_string_literal: true

# Items are handled by the StorageBox
class Item < ApplicationRecord
  belongs_to :storage_box
end
