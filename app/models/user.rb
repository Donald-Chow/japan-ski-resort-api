class User < ApplicationRecord
  if ENV.fetch("RAILS_ENV") && ENV.fetch("RAILS_ENV") == 'production'
    self.table_name = 'jp_ski_user'
  end
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  acts_as_token_authenticatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
