class CreateExercises < ActiveRecord::Migration
  def change
    create_table :exercises do |t|
      t.string :name
      t.integer :equipment_id
      t.string :force
      t.string :level
      t.string :mechanics_type
      t.string :exercise_type

      t.timestamps
    end
  end
end
