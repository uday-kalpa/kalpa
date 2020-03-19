class CreateUsersHistories < ActiveRecord::Migration
  def change
    create_table :users_histories do |t|
      t.integer :user_id
      t.integer :request_id
      t.text :algo

      t.timestamps null: false
    end
  end
end
