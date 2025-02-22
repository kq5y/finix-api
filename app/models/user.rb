class User < ApplicationRecord
  has_many :categories
  has_many :locations
  has_many :expenditures
  validates :uid, uniqueness: true
  validates :name, presence: true
end
