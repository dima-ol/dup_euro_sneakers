class CategoriesController < ApplicationController
  def show
    @category = Category.find(params[:id])
    # Only show products that are active and have more than 1 in stock
    @products = @category.products.available.includes(images_attachments: :blob)
    if params[:max].present?
      @products = @products.where("price <= ?", params[:max])
    end
    if params[:min].present?
      @products = @products.where("price >= ?", params[:min])
    end
  end
end
