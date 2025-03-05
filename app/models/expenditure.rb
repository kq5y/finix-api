class Expenditure < ApplicationRecord
  VALID_SORT_ORDERS = %w[asc desc].freeze
  VALID_SORT_KEYS = %w[id date amount].freeze

  belongs_to :category
  belongs_to :location
  belongs_to :payment_method
  belongs_to :user
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true

  scope :apply_sort, ->(sort_key, sort_order) {
    sort_key = sort_key.presence_in(VALID_SORT_KEYS) || "date"
    sort_order = sort_order.presence_in(VALID_SORT_ORDERS) || "desc"
    order(sort_key => sort_order)
  }
end
