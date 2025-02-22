class Expenditure < ApplicationRecord
  belongs_to :category
  belongs_to :location
  belongs_to :user
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
end
