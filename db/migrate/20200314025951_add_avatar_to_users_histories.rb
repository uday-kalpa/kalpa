class AddAvatarToUsersHistories < ActiveRecord::Migration
  def change
    add_column :users_histories, :avatar, :string
  end
end
