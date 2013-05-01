class Goal < ActiveRecord::Base
  attr_accessible :description, :due_date, :final_value, :start_value, :goal_type, :user_id, :name

  belongs_to :user

  GOAL_TYPES = {
    :lose_fat => "LF",
    :gain_muscle => "GM"
  }

  FRIENDLY_GOAL_TYPES = {
    "LF" => "Lose Fat",
    "GM" => "Gain Muscle"
  }

  def self.get_goal_types
    [
      ["", ""],
      ["Lose Fat", self::GOAL_TYPES[:lose_fat]],
      ["Gain Muscle", self::GOAL_TYPES[:gain_muscle]]
    ]
  end

  def self.get_friendly_goal_types(goal_type)
    return self::FRIENDLY_GOAL_TYPES[goal_type]
  end

  def self.validate_goal(goal_params, user)
    fields = {
      :name => "#goal-name",
      :goal_type => "#goal-type",
      :due_date => "#goal-due-date",
      :final_value => "#goal-final-value",
      :description => "#goal-description"
    }

    goal_hash = {
      "errors" => [],
      "params" => goal_params
    }

    if user.nil?
      goal_hash["errors"] << "Invalid User"
    end

    # check goal name
    if goal_params[:name].blank?
      goal_hash["errors"] << {
        "field" => fields[:name],
        "message" => "Please enter a goal name"
      }
    end

    # check goal weight
    if goal_params[:final_value].blank?
      goal_hash["errors"] << {
        "field" => fields[:final_value],
        "message" => "Please enter a goal weight"
      }
    end

    # check goal type
    if !self::GOAL_TYPES.values().include?(goal_params[:goal_type])
      goal_hash["errors"] << {
        "field" => fields[:goal_type],
        "message" => "Please choose a valid goal type"
      }
    end

    # check date
    begin
      due_date = DateTime.strptime(goal_params[:due_date], "%m/%d/%Y")
      if due_date < DateTime.now
        goal_hash["errors"] << {
          "field" => fields[:due_date],
          "message" => "Please set a date in the future"
        }
      else
        goal_hash["params"][:due_date] = due_date
      end
    rescue
      goal_hash["errors"] << {
        "field" => fields[:due_date],
        "message" => "Please select a valid date"
      }
    end

    # check goal type against values
    if goal_params[:goal_type] == self::GOAL_TYPES[:lose_fat]
      if goal_params[:final_value].to_f > user.weight
        goal_hash["errors"] << {
          "field" => fields[:final_value],
          "message" => "To lose fat, you must enter a value less than your current weight"
        }
      end
    elsif goal_params[:goal_type] == self::GOAL_TYPES[:gain_muscle]
      if goal_params[:final_value].to_f < user.weight
        goal_hash["errors"] << {
          "field" => fields[:final_value],
          "message" => "To gain muscle, you must enter a value greater than your current weight"
        }
      end
    end

    return goal_hash
  end

end
