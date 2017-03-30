class Schema < ActiveRecord::Migration
  def change
    create_table :users, force: true do |t|
      t.string :username
      t.datetime :registration
      t.string :condition
      t.boolean :invited, default: false
    end
  end
end
