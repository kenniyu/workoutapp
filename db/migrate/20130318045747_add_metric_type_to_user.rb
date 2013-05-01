class AddMetricTypeToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :weight_unit, :string, :default => "lbs"
    add_column :users, :height_unit, :string, :default => "in"
  end

  def self.down
    remove_column :users, :weight_unit
    remove_column :users, :height_unit
  end
end
