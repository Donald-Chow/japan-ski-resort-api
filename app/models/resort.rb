class Resort < ApplicationRecord
  include PgSearch::Model
  belongs_to :user

  validates :name, presence: true
  validates :prefecture, presence: true

  pg_search_scope :search_by_name_and_location,
                  against: [:name, :town, :prefecture, :address],
                  using: {tsearch: {prefix: true}}
end
