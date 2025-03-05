class PaymentMethod < ApplicationRecord
  VALID_SORT_ORDERS = %w[asc desc].freeze
  VALID_SORT_KEYS = %w[id].freeze
  VALID_PAYMENT_TYPES = %w[cash card qrcode other].freeze

  def as_json(options = {})
    super(options.merge(except: [ :user_id ]))
  end

  belongs_to :user
  has_many :expenditures
  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :payment_type, inclusion: { in: VALID_PAYMENT_TYPES }, allow_nil: true

  scope :apply_sort, ->(sort_key, sort_order) {
    sort_key = sort_key.presence_in(VALID_SORT_KEYS) || "id"
    sort_order = sort_order.presence_in(VALID_SORT_ORDERS) || "asc"
    order(sort_key => sort_order)
  }
end
