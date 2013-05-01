class AddColumnsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :age, :integer
    add_column :users, :gender, :string
    add_column :users, :weight, :float
    add_column :users, :height, :float
    add_column :users, :body_fat_pct, :float
  end

  def self.down
    remove_column :users, :age
    remove_column :users, :gender
    remove_column :users, :weight
    remove_column :users, :height
    remove_column :users, :body_fat_pct
  end
end
