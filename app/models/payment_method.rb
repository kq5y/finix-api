# Model for PaymentMethod
class PaymentMethod < ApplicationRecord
  VALID_SORT_ORDERS = %w[asc desc].freeze
  VALID_SORT_KEYS = %w[id].freeze
  VALID_PAYMENT_TYPES = %w[cash card qrcode other].freeze

  def as_json(options = {})
    super(options.merge(except: %i[user_id discarded_at]))
  end

  belongs_to :user
  has_many :expenditures, dependent: nil
  validates :payment_type, inclusion: { in: VALID_PAYMENT_TYPES }, allow_nil: true

  before_discard do
    if expenditures.exists?
      errors.add(:base, "Cannot delete category with expenditures")
      throw :abort
    end
  end

  scope :apply_sort, lambda { |sort_key, sort_order|
    sort_key = sort_key.presence_in(VALID_SORT_KEYS) || "id"
    sort_order = sort_order.presence_in(VALID_SORT_ORDERS) || "asc"
    order(sort_key => sort_order)
  }
end
