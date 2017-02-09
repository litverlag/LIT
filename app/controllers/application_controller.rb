class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_filter :check_permission

  def check_permission
    puts controller_name
    unless ["application","sessions"].include? controller_name
      if controller_name != current_user.department and current_user.department != "admin"
        redirect_to controller: :application, action: :index
      end
    end
  end

  def index
    redirect_to controller: current_user.department != "admin" ? current_user.department : "chef", action: "index"
    puts "jaaaahaaa"
  end
end
