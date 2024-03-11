class Resort < ApplicationRecord
  validates :name, presence: true
  validates :prefecture, presence: true
end
