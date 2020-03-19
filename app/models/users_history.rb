class UsersHistory < ActiveRecord::Base
  
  mount_uploader :avatar, AvatarUploader

  belongs_to  :user
  serialize :algo
end