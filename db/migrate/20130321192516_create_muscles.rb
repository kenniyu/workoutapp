class CreateMuscles < ActiveRecord::Migration
  def change
    create_table :muscles do |t|
      t.string :name
      t.string :alias

      t.timestamps
    end
  end
end
