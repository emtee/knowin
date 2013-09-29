class ApplicationController < ActionController::Base
  layout :layout_by_resource
  # before_filter :authenticate_user!

  protected

  def layout_by_resource
    if devise_controller?# && resource_name == :admin
      "login"
    else
      "application"
    end
  end

end
