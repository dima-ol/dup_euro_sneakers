class CheckoutsController < ApplicationController
  def new
    @order = Order.new
  end

  def create
    cart = checkout_cart

    if cart.blank?
      flash[:alert] = "Ваш кошик порожній"
      redirect_to cart_path and return
    end

    if params[:order].present?
      @order = Order.new(order_params)
      @order.fulfilled = false
      @order.total = cart.sum { |item| item["price"].to_i * item["quantity"].to_i }

      if @order.save
        create_order_products(@order, cart)
        session[:cart] = nil
        flash[:notice] = "Замовлення успішно створено!"
        redirect_to success_path and return
      end

      render :new, status: :unprocessable_entity and return
    end

    line_items = cart.map do |item|
      product = Product.find(item["id"])
      product_stock = Stock.find_by(product_id: item["id"])

      if product_stock.amount < item["quantity"].to_i
        render json: {
          error: "Not enough stock for #{product.name} in size #{item["size"]}. Only #{product_stock.amount} left."
        }, status: 400
        return
      end

      {
        name: item["name"],
        quantity: item["quantity"].to_i,
        price: item["price"].to_f,
        size: item["size"],
        product_id: product.id,
        product_stock_id: product_stock.id
      }
    end

    order = Order.create!(
      total: line_items.sum { |item| item[:price] * item[:quantity] },
      fulfilled: false
    )

    puts "line_items: #{line_items}"

    merchant_code = "YOUR_MERCHANT_CODE"
    base_url = "https://secure.2checkout.com/checkout/purchase"

    first_item = line_items.first

    payload = {
      sid: merchant_code,
      mode: "2CO",
      li_0_type: "product",
      li_0_name: first_item[:name],
      li_0_price: first_item[:price],
      li_0_quantity: first_item[:quantity],
      currency_code: "UAH",
      x_receipt_link_url: "https://electro-backup.onrender.com/success"
    }

    redirect_url = "#{base_url}?#{payload.to_query}"

    render json: { url: redirect_url }
  end

  def success
    render :success
  end

  def cancel
    render :cancel
  end

  private

  def checkout_cart
    cart_param = params[:cart] || params[:cart_data]

    return [] if cart_param.blank?
    return cart_param if cart_param.is_a?(Array)

    JSON.parse(cart_param) rescue []
  end

  def create_order_products(order, cart)
    cart.each do |item|
      product = Product.find(item["id"])
      stock = Stock.find_by(product_id: product.id)

      OrderProduct.create!(order: order, product: product, quantity: item["quantity"].to_i, size: item["size"])
      stock&.decrement!(:amount, item["quantity"].to_i)
    end
  end

  def order_params
    params.require(:order).permit(:customer_email, :phone, :address)
  end
end
  