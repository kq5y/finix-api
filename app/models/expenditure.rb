class Expenditure < ApplicationRecord
  VALID_SORT_ORDERS = %w[asc desc].freeze
  VALID_SORT_KEYS = %w[id date amount].freeze

  def as_json(options = {})
    super(options.merge(
      include: {
        category: { except: [ :user_id, :discarded_at ] },
        location: { except: [ :user_id, :discarded_at ] },
        payment_method: { except: [ :user_id, :discarded_at ] }
      },
      except: [ :user_id, :category_id, :location_id, :payment_method_id, :discarded_at ]
    ))
  end

  belongs_to :category, optional: true
  belongs_to :location, optional: true
  belongs_to :payment_method, optional: true
  belongs_to :user
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
  validate :validate_category_ownership
  validate :validate_location_ownership
  validate :validate_payment_method_ownership

  scope :apply_sort, ->(sort_key, sort_order) {
    sort_key = sort_key.presence_in(VALID_SORT_KEYS) || "date"
    sort_order = sort_order.presence_in(VALID_SORT_ORDERS) || "desc"
    order(sort_key => sort_order)
  }

  private

  def validate_category_ownership
    return unless category_id.present?
    return if user.categories.exists?(id: category_id)
    errors.add(:category, "must belong to the current user")
  end

  def validate_location_ownership
    return unless location_id.present?
    return if user.locations.exists?(id: location_id)
    errors.add(:location, "must belong to the current user")
  end

  def validate_payment_method_ownership
    return unless payment_method_id.present?
    return if user.payment_methods.exists?(id: payment_method_id)
    errors.add(:payment_method, "must belong to the current user")
  end
end
