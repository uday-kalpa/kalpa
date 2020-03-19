class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :user_id
      t.string :name
      t.string :eye_type
      t.string :medical_history
      t.string :sex
      t.integer :age
      t.integer :IOP

      t.timestamps null: false
    end
  end
end
