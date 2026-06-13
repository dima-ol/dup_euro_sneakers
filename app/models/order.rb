class Order < ApplicationRecord
  has_many :order_products, dependent: :destroy, inverse_of: :order
  has_many :products, through: :order_products

  accepts_nested_attributes_for :order_products, allow_destroy: true, reject_if: :all_blank
end
