class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :uid,         null: false
      t.string :login,       null: false
      t.string :email,       null: false
      t.string :name
      t.string :token,       null: false

      t.timestamps null: false
    end

    add_index :users, [:uid], unique: true
  end
end