module Api
  class BaseController < ActionController::Base
    # before_action :restrict_access unless Rails.env.development?

    def render_json_error(status, error_text, opts = {})
      render json: { error: error_text }.merge(opts).to_json, status: status
    end
    
    # private

    # def restrict_access
    # end
  end
end