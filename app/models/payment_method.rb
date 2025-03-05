class PaymentMethod < ApplicationRecord
  VALID_SORT_ORDERS = %w[asc desc].freeze
  VALID_SORT_KEYS = %w[id].freeze

  def as_json(options = {})
    super(options.merge(except: [ :user_id ]))
  end

  belongs_to :user
  has_many :expenditures
  validates :name, presence: true, uniqueness: { scope: :user_id }

  scope :apply_sort, ->(sort_key, sort_order) {
    sort_key = sort_key.presence_in(VALID_SORT_KEYS) || "id"
    sort_order = sort_order.presence_in(VALID_SORT_ORDERS) || "asc"
    order(sort_key => sort_order)
  }
end
