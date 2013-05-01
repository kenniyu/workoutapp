class AddActivityLevelToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :activity_level, :integer
  end

  def self.down
    remove_column :users, :activity_level
  end
end
