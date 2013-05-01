class UserController < ApplicationController
  before_filter :authenticate_user!

  def edit_profile
    @activity_levels = [
      ['Little or No Exercise', 1],
      ['Light Exercise/Sports 1-3 Days a Week', 2],
      ['Moderate Exercise/Sports 3-5 Days a Week', 3],
      ['Hard Exercise/Sports 6-7 Days a Week', 4],
      ['Very Hard Exercise/Sports & Physical Job or 2x Training', 5]
    ]
    @heights = Metrics.get_heights
    @body_metrics = Metrics.get_body_metrics(current_user)

  end

  def update_profile
    current_user.update_attributes(params[:user])
    redirect_to profile_path(current_user.id) and return
  end

  def profile
    @user = User.find_by_id(params[:user_id]) || current_user

    if @user.nil?
      redirect_to profile_path(current_user.id) and return
    end

    @activity_level = Metrics.get_activity_levels(@user.activity_level)
    @body_metrics = Metrics.get_body_metrics(@user)
    @height = Metrics.get_ft_and_in(@user.height)

  end
end
