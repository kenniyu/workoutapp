class Metrics < ActiveRecord::Base
  def self.get_heights
    heights = {
      :us => [],
      :si => []
    }
    (48..119).each do |inch|
      feet = inch/12
      inches = inch % 12
      metric_str = "#{feet}' #{inches}\""
      metric_val = inch
      select_option = [metric_str, metric_val]
      heights[:us] << select_option
    end

    (120..305).each do |cm|
      heights[:si] << "#{cm} cm"
    end
    return heights
  end

  def self.get_bmr_multiplier(activity_level)
    return false if activity_level.nil? || !(1..5).include?(activity_level)

    bmr_multipliers = {
      1 => 1.2,
      2 => 1.375,
      3 => 1.55,
      4 => 1.725,
      5 => 1.9
    }
    return bmr_multipliers[activity_level]
  end

  def self.get_body_metrics(user)
    return nil if user.nil?
    activity_level = user.activity_level
    return nil if activity_level.nil? || user.weight.nil? || user.height.nil? || user.age.nil?


    if user.gender && user.gender == 'Female'
      bmr = 655 + (4.35 * user.weight) + (4.7 * user.height) - (4.7 * user.age)
    else
      bmr = 66 + (6.23 * user.weight) + (12.7 * user.height) - (6.8 * user.age)
    end
    hbf = bmr * self.get_bmr_multiplier(activity_level)
    lbm = (100 - user.body_fat_pct)/100 * (user.weight)

    info = {
      :bmr => "%.2f" % bmr,
      :hbf => "%.2f" % hbf,
      :lbm => "%.2f" % lbm
    }
    return info
  end

  def self.get_activity_levels(activity_level)
    return nil if !(1..5).include?(activity_level)
    activity_levels = {
      1 => 'Little or No Exercise',
      2 => 'Light Exercise/Sports 1-3 Days a Week',
      3 => 'Moderate Exercise/Sports 3-5 Days a Week',
      4 => 'Hard Exercise/Sports 6-7 Days a Week',
      5 => 'Very Hard Exercise/Sports & Physical Job or 2x Training'
    }

    return activity_levels[activity_level]
  end

  def self.get_ft_and_in(height)
    return nil if height.nil?
    feet = (height.to_i)/12
    inches = (height.to_i)%12
    return "#{feet}' #{inches}\""
  end

  def self.get_daily_target_calories(user, goal)
    start_value = goal.start_value
    final_value = goal.final_value
    goal_type = goal.goal_type
    if goal_type == Goal::GOAL_TYPES[:lose_fat]
      # assumes lb
      current_date = DateTime.now
      final_date = goal.due_date.to_datetime
      logger.debug(current_date)
      logger.debug(final_date)
      days_until_goal = (final_date - current_date).round

      weight_loss = start_value - final_value
      weight_loss_per_day = weight_loss/days_until_goal
      logger.debug(days_until_goal)

      daily_caloric_deficit = weight_loss_per_day * 3500
      nutrition_ratio = goal.nutrition / 100.to_f
      exercise_ratio = goal.exercise / 100.to_f

      daily_exercise_caloric_deficit = daily_caloric_deficit * exercise_ratio
      daily_nutrition_caloric_deficit = daily_caloric_deficit * nutrition_ratio

      target_calories_per_day = self.get_body_metrics(user)[:hbf].to_f - daily_caloric_deficit
      target_calories_per_day_with_exercise = target_calories_per_day + daily_exercise_caloric_deficit

      return {
        :days_until_goal => days_until_goal,
        :daily_caloric_deficit => daily_caloric_deficit.round,
        :daily_exercise_caloric_deficit => (daily_exercise_caloric_deficit).round,
        :daily_nutrition_caloric_deficit => (daily_nutrition_caloric_deficit).round,
        :calories_to_gain_via_nutrition => target_calories_per_day_with_exercise.round,
        :calories_to_burn_per_day_via_exercise => daily_exercise_caloric_deficit.round,
        :target_calories_per_day => target_calories_per_day.round
      }
    end
  end
end
