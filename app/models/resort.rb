class Resort < ApplicationRecord
  if ENV.fetch("RAILS_ENV") && ENV.fetch("RAILS_ENV") == 'production'
    self.table_name = 'jp_ski_resorts'
  end

  validates :name, presence: true
  validates :prefecture, presence: true
end
