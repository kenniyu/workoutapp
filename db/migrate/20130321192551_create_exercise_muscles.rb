class CreateExerciseMuscles < ActiveRecord::Migration
  def change
    create_table :exercise_muscles do |t|
      t.integer :exercise_id
      t.integer :muscle_id
      t.string :focus

      t.timestamps
    end
  end
end
