class User < ApplicationRecord
  has_many :categories
  has_many :locations
  has_many :payment_methods
  has_many :expenditures
  validates :uid, uniqueness: true
  validates :username, presence: true
end
