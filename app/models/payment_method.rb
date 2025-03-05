class PaymentMethod < ApplicationRecord
  belongs_to :user
  has_many :expenditures
  validates :name, presence: true, uniqueness: { scope: :user_id }
end
