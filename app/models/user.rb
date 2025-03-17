# Model for User
class User < ApplicationRecord
  def as_json(options = {})
    super(options.merge(except: [:discarded_at]))
  end

  has_many :categories, dependent: nil
  has_many :locations, dependent: nil
  has_many :payment_methods, dependent: nil
  has_many :expenditures, dependent: nil
  validates :uid, uniqueness: true
  validates :username, presence: true

  after_discard do
    categories.discard_all
    locations.discard_all
    payment_methods.discard_all
    expenditures.discard_all
  end
end
