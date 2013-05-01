class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.integer :user_id
      t.string :type
      t.datetime :due_date
      t.float :start_value
      t.float :final_value
      t.string :description

      t.timestamps
    end
  end
end
