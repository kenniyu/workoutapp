class GoalsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @goals = current_user.goals
  end

  def show
    @goal = Goal.find_by_id(params[:id])
    if request.xhr?
      render :nothing => true and return if @goal.user.id != current_user.id
      @ajax = true
    else
      redirect_to goals_path and return if @goal.nil?
    end
    @goal_user = @goal.user

    @friendly_goal_type = Goal.get_friendly_goal_types(@goal.goal_type)

    @body_metrics = Metrics.get_body_metrics(@goal_user)

    if @goal.goal_type == Goal::GOAL_TYPES[:gain_muscle]
      # 250 - 500 caloric surplus per day
      @calories_per_day = (@body_metrics[:hbf].to_f * 2 + 750)/2
    elsif @goal.goal_type == Goal::GOAL_TYPES[:lose_fat]
      @calories_per_day_hash = Metrics.get_daily_target_calories(@goal_user, @goal)
    end
  end

  def new
    if current_user.has_complete_profile?
      @new_goal = Goal.new
      @goal_types = Goal.get_goal_types
    end
  end

  def create
    @goal_hash = Goal.validate_goal(params[:goal], current_user)
    if @goal_hash["errors"].present?
      @success = false
      logger.debug(@goal_hash)
    else
      params[:goal][:start_value] = current_user.weight
      params[:goal][:due_date] = @goal_hash["params"][:due_date]
      @goal = current_user.goals.new(params[:goal])
      if @goal.save
        @success = true
      else
        @success = false
      end
    end
  end

  def destroy
    @goal = Goal.find_by_id(params[:id])
    redirect_to goals_path and return if @goal.nil? || @goal.user.id != current_user.id
    @goal.destroy
    redirect_to goals_path and return
  end

  def update
    @goal = Goal.find_by_id(params[:id])
    render :nothing => true and return if @goal.nil?
    render :nothing => true and return if @goal.user.id != current_user.id

    goal_change = params[:change]
    if goal_change == "ne-ratio"
      @nutrition_pct = params[:nutrition]
      @exercise_pct = params[:exercise]
      @goal.nutrition = @nutrition_pct
      @goal.exercise = @exercise_pct
      if @goal.save
        @success = true
        @calories_per_day_hash = Metrics.get_daily_target_calories(@goal.user, @goal)
      end
    end
    render 'update' and return
  end
end
