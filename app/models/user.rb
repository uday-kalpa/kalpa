class User < ActiveRecord::Base
  
  has_many :users_histories
  validates_uniqueness_of :user_id
  mount_uploader :avatar, AvatarUploader

end
