class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
   include Rails.application.routes.url_helpers

  #The method access_denied would be defined in application_controller.rb.
  # Here is one example that redirects the user from the page they don't
  # have permission to access to a resource they have permission to access
  # (organizations in this case), and also displays the error message in the browser:
  def access_denied(exception)
    redirect_to "/admin/access_denied"
  end

  before_action :set_locale

end
