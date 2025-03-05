class Expenditure < ApplicationRecord
  VALID_SORT_ORDERS = %w[asc desc].freeze
  VALID_SORT_KEYS = %w[id date amount].freeze

  def as_json(options = {})
    super(options.merge(
      include: {
        category: { except: :user_id },
        location: { except: :user_id },
        payment_method: { except: :user_id }
      },
      except: [ :user_id, :category_id, :location_id, :payment_method_id ]
    ))
  end

  belongs_to :category, optional: true
  belongs_to :location, optional: true
  belongs_to :payment_method, optional: true
  belongs_to :user
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true

  scope :apply_sort, ->(sort_key, sort_order) {
    sort_key = sort_key.presence_in(VALID_SORT_KEYS) || "date"
    sort_order = sort_order.presence_in(VALID_SORT_ORDERS) || "desc"
    order(sort_key => sort_order)
  }
end
