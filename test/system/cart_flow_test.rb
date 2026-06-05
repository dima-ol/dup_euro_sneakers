require "application_system_test_case"

class CartFlowTest < ApplicationSystemTestCase
  test "add product to cart and remove it with toast notifications" do
    category = Category.create!(name: "Тренди", active: true)
    product = Product.create!(name: "Test Sneaker", description: "Test description", price: 1000, category: category, active: true)
    Stock.create!(product: product, size: "M", amount: 5)

    visit product_path(product)

    click_on "M"
    click_on "Додати до корзини"

    assert_text "Test Sneaker додано до кошика"

    visit cart_path
    assert_text "Підсумок: 1000 грн"

    click_on "Видалити"
    assert_text "Test Sneaker видалено з кошика"
    assert_no_text "Підсумок: 1000 грн"
  end

  test "clear cart shows notification and empties cart" do
    category = Category.create!(name: "Тренди", active: true)
    product = Product.create!(name: "Clear Sneaker", description: "Test clear cart", price: 500, category: category, active: true)
    Stock.create!(product: product, size: "L", amount: 3)

    visit product_path(product)
    click_on "L"
    click_on "Додати до корзини"

    visit cart_path
    click_on "Очистити кошик"

    assert_text "Кошик очищено"
    assert_no_text "Підсумок: 500 грн"
  end
end
