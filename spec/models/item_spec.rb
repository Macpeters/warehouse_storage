# frozen_string_literal: true

require 'rails_helper'

describe Item do

  describe 'volume' do 
    it 'returns the volume of the item' do
      item = FactoryBot.create(:item, length: 10, width: 5, height: 2)
      expect(item.volume).to eql(item.width * item.length * item.height)
    end

    it 'handles nil values without complaining' do
      item = FactoryBot.create(:item, length: nil, width: 5, height: 2)
      expect(item.volume).to eql(0)
    end
  end
end
