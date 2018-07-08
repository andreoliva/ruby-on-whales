class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!, except: [:home]

  def home
  end

  def users
    @users = User.all
  end

  def after_sign_in_path_for(resource)
    users_path
  end
end
