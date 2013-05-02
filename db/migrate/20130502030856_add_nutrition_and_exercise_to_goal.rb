class AddNutritionAndExerciseToGoal < ActiveRecord::Migration
  def self.up
    add_column :goals, :nutrition, :integer, :default => 70
    add_column :goals, :exercise, :integer, :default => 30
  end

  def self.down
    remove_column :goals, :nutrition
    remove_column :goals, :exercise
  end
end
