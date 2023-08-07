class Resort < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :prefecture, presence: true
end
