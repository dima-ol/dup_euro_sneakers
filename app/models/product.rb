class Product < ApplicationRecord
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [50, 50]
    attachable.variant :medium, resize_to_limit: [250, 250]
  end

  belongs_to :category
  has_many :stocks
  has_many :order_products
  has_many :orders, through: :order_products

  # Only show products that are activated in admin and have total stock > 1
  scope :available, -> {
    joins(:stocks)
      .where(active: true)
      .group("products.id")
      .having("COALESCE(SUM(stocks.amount), 0) > ?", 1)
  }

  def display_name
    if price.present?
      "#{name} — #{price} грн"
    else
      name
    end
  end
end
