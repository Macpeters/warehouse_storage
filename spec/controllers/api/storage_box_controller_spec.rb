# frozen_string_literal: true

require 'rails_helper'

describe Api::StorageBoxController, type: :controller do
  describe 'rspec' do
    it 'runs a test' do
      expect('hi').to eql('hi')
    end

    it 'fails a test' do
      expect('hi').to eql('bye')
    end
  end
end
